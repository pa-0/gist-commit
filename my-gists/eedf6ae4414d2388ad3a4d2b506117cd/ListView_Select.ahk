; ListView with Search by wildcard
; Selection := ListView_Select(LVArray,Title:="",Name)
; LVArray: can be multidimensional array, each row matching a ListView row
; Name : Column Names separated by |
ListView_Select(LVArray,Title:="", Name := "Name") 

{
static LVSSearchValue
static LVSListView
Gui, ListView_Select:New,,%Title%
Gui, Add, Text, ,Search:
Gui, Add, Edit, w400 vLVSSearchValue gLVSSearch
Gui, Add, ListView, grid w400  AltSubmit vLVSListView hwndHLVSListView gLVSListView, %Name%

If InStr(Name,"|") { ; multiple columns
    for m, row in LVArray {
        args := {}
		for n, col in row {
            args[n] := LVArray[m,n]
        }
            
    LV_Add("",args*)
    }	
} Else {
    For k,v In LVArray
        LV_Add("", v)
}

; https://www.autohotkey.com/boards/viewtopic.php?t=83495
LV_ModifyCol()  ; Auto-adjust the column widths.

Gui, Show
ListView_WantReturn(HLVSListView) ; <<< added 

; main wait loop
Gui, +LastFound
WinWaitClose

return Selection

LVSSearch:
Gui,Submit,NoHide
GuiControl, -Redraw, LV
LV_Delete()

If (LVSSearchValue = "")
    sPat := ".*"
Else {
    sPat := StrReplace(LVSSearchValue,"*",".*")
    If (SubStr(LVSSearchValue,1,1) != "*")
        sPat := "^" . sPat
}


If InStr(Name,"|") { ; multiple columns
    for m, row in LVArray {
        args := {}
		for n, col in row {
            args[n] := LVArray[m,n]
        }
        If RegExMatch(args[1], "i)" . sPat)         
            LV_Add("",args*)
    }	
} Else {
    For k,v In LVArray
        If RegExMatch(v, "i)" . sPat) ; ignore case
            LV_Add("", v)
}


GuiControl, +Redraw, LV

LV_Modify(1, "Select")
Return

LVSListView:
if (A_GuiEvent = "DoubleClick")
    {
        Selection:= A_EventInfo  ; Get the text from the row's first field.
        Gui, Destroy
        return
    }
;Gui, ListView, %A_GuiControl% ; <<< added
If (A_GuiEvent == "K") && (A_EventInfo = 13) ; VK_RETURN = 13 (0x0D)
{
   Selection:=LV_GetNext()
   Gui, Destroy
   return
}
return


ListView_SelectGuiClose:     ; {Alt+F4} pressed, [X] clicked
ListView_SelectGuiEscape:    ; {Esc} pressed
    Selection := 0
    Gui, Destroy
return
}