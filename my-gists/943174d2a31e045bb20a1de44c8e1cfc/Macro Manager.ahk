#Requires AutoHotkey v2.0

^!t::ShowMacroSearch()

MacroFilePath := A_ScriptDir . "\macros.txt"

global MacroTypeMap := Map()
MacroTypeMap["1"] := "Send"
MacroTypeMap["2"] := "Run"

LoadMacros() {
    macros := []
    if FileExist(MacroFilePath) {
        try {
            fileContent := FileRead(MacroFilePath, "UTF-8")
            lines := StrSplit(fileContent, "`n", "`r")
            currentMacro := Map()
            for index, line in lines {
                if (line = "") {
                    if (currentMacro.Has("name") && currentMacro.Has("type") && currentMacro.Has("command")) {
                        macros.Push({name: currentMacro["name"], type: currentMacro["type"], command: currentMacro["command"]})
                        currentMacro := Map()
                    }
                } else {
                    parts := StrSplit(line, "=", , 2)
                    if (parts.Length = 2) {
                        currentMacro[parts[1]] := parts[2]
                    }
                }
            }
            if (currentMacro.Has("name") && currentMacro.Has("type") && currentMacro.Has("command")) {
                macros.Push({name: currentMacro["name"], type: currentMacro["type"], command: currentMacro["command"]})
            }
        } catch as err {
            MsgBox("Error loading macros: " . err.Message . "`nFile path: " . MacroFilePath)
        }
    }
    return macros
}

SaveMacros(macros) {
    fileContent := ""
    for macro in macros {
        fileContent .= "name=" . macro.name . "`n"
        fileContent .= "type=" . macro.type . "`n"
        fileContent .= "command=" . macro.command . "`n`n"
    }
    try {
        FileDelete(MacroFilePath) ; Delete existing file before saving new content
        FileAppend(fileContent, MacroFilePath, "UTF-8-RAW")
    } catch as err {
        MsgBox("Error saving macros: " . err.Message)
    }
}

Macros := LoadMacros()

ShowMacroSearch() {
    macroGui := Gui("+AlwaysOnTop", "Macro Search")
    searchBox := macroGui.Add("Edit", "w400 vSearchBox")
    macroList := macroGui.Add("ListView", "w400 r10", ["Name", "Type", "Command"])
    addButton := macroGui.Add("Button", "w100", "Add Macro")
    editButton := macroGui.Add("Button", "w100 x+10", "Edit Macro")
    deleteButton := macroGui.Add("Button", "w100 x+10", "Delete Macro") ; Add delete button

    macroList.ModifyCol(1, 200)
    macroList.ModifyCol(2, 80)
    macroList.ModifyCol(3, 120)

    RefreshMacroList(macroList)

    searchBox.OnEvent("Change", (*) => UpdateList(macroList, searchBox))
    macroList.OnEvent("DoubleClick", (*) => ExecuteMacro(macroList))
    addButton.OnEvent("Click", (*) => AddEditMacro(macroList))
    editButton.OnEvent("Click", (*) => EditSelectedMacro(macroList))
    deleteButton.OnEvent("Click", (*) => DeleteSelectedMacro(macroList)) ; Attach delete event

    macroGui.OnEvent("Close", (*) => macroGui.Destroy())
    macroGui.OnEvent("Escape", (*) => macroGui.Destroy())

    enterHotkey := HotIfWinactive("ahk_id " macroGui.Hwnd)
    Hotkey("Enter", (*) => ExecuteFirstVisibleMacro(macroList), enterHotkey)

    macroGui.Show()
    searchBox.Focus()
}

RefreshMacroList(macroList) {
    macroList.Delete()
    for macro in Macros {
        typeText := MacroTypeMap[macro.type] ; Convert type number to text
        macroList.Add(, macro.name, typeText, macro.command)
    }
    if (macroList.GetCount() > 0) {
        macroList.Modify(1, "+Select +Focus")
    }
}

UpdateList(macroList, searchBox) {
    searchText := Trim(StrLower(searchBox.Value))
    searchWords := StrSplit(searchText, A_Space)
    macroList.Delete()
    
    if (searchText != "") {
        for macro in Macros {
            matchFound := false
            macroNameLower := StrLower(macro.name)
            macroCommandLower := StrLower(macro.command)
            
            for word in searchWords {
                if (word != "" && (InStr(macroNameLower, word) || InStr(macroCommandLower, word))) {
                    matchFound := true
                    break
                }
            }
            
            if (matchFound) {
                typeText := MacroTypeMap[macro.type] ; Convert type number to text
                macroList.Add(, macro.name, typeText, macro.command)
            }
        }
    } else {
        RefreshMacroList(macroList)
    }
    
    if (macroList.GetCount() > 0) {
        macroList.Modify(1, "+Select +Focus")
    }
}

ExecuteFirstVisibleMacro(macroList) {
    itemCount := macroList.GetCount()
    
    if (itemCount > 0) {
        macroName := macroList.GetText(1, 1)
        macroType := macroList.GetText(1, 2) ; This is already the text like "Send" or "Run"
        macroCommand := macroList.GetText(1, 3)
        
        ; No need to map again because macroType is already the descriptive text
        macroList.Gui.Destroy()
        
        if (macroType == "Send") {
            Send(macroCommand)
        } else if (macroType == "Run") {
            Run(macroCommand)
        }
    }
}

ExecuteMacro(macroList) {
    if (selectedRow := macroList.GetNext(0, "F")) {
        macroName := macroList.GetText(selectedRow, 1)
        macroType := macroList.GetText(selectedRow, 2) ; This is already the text like "Send" or "Run"
        macroCommand := macroList.GetText(selectedRow, 3)
        
        macroList.Gui.Destroy()
        
        if (macroType == "Send") {
            Send(macroCommand)
        } else if (macroType == "Run") {
            Run(macroCommand)
        }
    }
}

AddEditMacro(macroList, editIndex := 0) {
    editGui := Gui("+AlwaysOnTop", (editIndex ? "Edit" : "Add") . " Macro")
    editGui.Add("Text", "x10 y10", "Name:")
    nameEdit := editGui.Add("Edit", "x10 y30 w280 vName")
    editGui.Add("Text", "x10 y60", "Type:")
    typeDropDown := editGui.Add("DropDownList", "x10 y80 w280 vType Choose1", ["Send", "Run"])
    editGui.Add("Text", "x10 y110", "Command:")
    commandEdit := editGui.Add("Edit", "x10 y130 w280 vCommand")
    saveButton := editGui.Add("Button", "x10 y170 w100", "Save")
    cancelButton := editGui.Add("Button", "x120 y170 w100", "Cancel")

    if (editIndex) {
        macro := Macros[editIndex]
        nameEdit.Value := macro.name
        typeDropDown.Value := MacroTypeMap[macro.type] ; Set dropdown to text value
        commandEdit.Value := macro.command
    }

    saveButton.OnEvent("Click", (*) => SaveMacro(editGui, macroList, editIndex))
    cancelButton.OnEvent("Click", (*) => editGui.Destroy())

    editGui.Show()
}

SaveMacro(editGui, macroList, editIndex) {
    ; Convert the type back to the key for saving
    typeKey := MacroTypeMap[editGui["Type"].Value]
    newMacro := {name: editGui["Name"].Value, type: typeKey, command: editGui["Command"].Value}
    
    if (editIndex) {
        Macros[editIndex] := newMacro
    } else {
        Macros.Push(newMacro)
    }
    
    SaveMacros(Macros)
    RefreshMacroList(macroList)
    editGui.Destroy()
}

EditSelectedMacro(macroList) {
    if (selectedRow := macroList.GetNext(0, "F")) {
        AddEditMacro(macroList, selectedRow)
    }
}

DeleteSelectedMacro(macroList) {
    if (selectedRow := macroList.GetNext(0, "F")) {
        Macros.RemoveAt(selectedRow) ; Remove the selected macro from the list
        SaveMacros(Macros) ; Save the updated list to the file
        RefreshMacroList(macroList) ; Refresh the list view
    }
}
