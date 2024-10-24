; Tested and working using AutoHotkey v1.1.33.09

; Uppercaseing, Lowercasing, and Title casing highlighted text in any editable window is used as an example.

; Create the popup menu, assign to the variable "CaseMenu" (rename as desired)
Menu, CaseMenu, Add, Title Case, AltMenuHandler
Menu, CaseMenu, Add, Upper Case, AltMenuHandler
Menu, CaseMenu, Add, Lower Case, AltMenuHandler

; Create and add a sub-menu for Links
Menu, SubMenu, Add, a, SubMenuHandler
Menu, SubMenu, Add, b, SubMenuHandler
Menu, SubMenu, Add, c, SubMenuHandler
Menu, CaseMenu, Add, Example Submenu, :SubMenu

; Assign created menu to a shortcut. In this case, Alt + Right Click
Alt & RButton::Menu, CaseMenu, Show

; Handler for the right-click menu. Could be as simple as the Switch statement (see SubMenuHandler for an example of that).
; Here, I've added some extra indirection in order to reuse my Regex_ClipboardHandler() function.
AltMenuHandler:
    Sleep 100
    Switch A_ThisMenuItem
    {
        Case "Title Case":
            Regex_ClipboardHandler("TitleCase")  
        Case "Upper Case":
            Regex_ClipboardHandler("UpperCase")
        Case "Lower Case":
            Regex_ClipboardHandler("LowerCase")
    }
return

SubMenuHandler:
    Sleep 100
    Switch A_ThisMenuItem
    {
        Case "a":
            MsgBox You clicked sub-menu option "a"!
        Case "b":
            MsgBox You clicked sub-menu option "b"!
        Case "c":
            MsgBox You clicked sub-menu option "c"!
    }
return

Regex_ClipboardHandler(regexLogic, optionalParam1=""){

    function := Func(regexLogic)

    oldclip := Clipboard

    Clipboard = 
    SendInput, ^c
    ClipWait 0 ;pause for Clipboard data
    
    if (optionalParam1 = "")
    {
        Clipboard := function.Call(Clipboard)

    }
    else 
    {
        Clipboard := function.Call(Clipboard, optionalParam1)
    }    
    
    Sleep 100
        SendInput, ^v
    Sleep 200
    Clipboard := oldclip

}

; List of functions that actually execute Regex. Each takes in a string and returns a string.

SomeLower(subString){
    done := subString
    matches := {" And ": " and "
                ," As ": " as "
                ," But ": " but "
                ," For ": " for "
                ," If ": " if "
                ," Nor ": " nor "
                ," Or ": " or "
                ," So ": " so "
                ," Yet ": " yet "
                ," A ": " a "
                ," An ": " an "
                ," The ": " the "
                ," At ": " at "
                ," By ": " by "
                ," In ": " in "
                ," Of ": " of "
                ," Off ": " off "
                ," On ": " on "
                ," Per ": " per "
                ," To ": " to "
                ," Up ": " up "
                ," Via ": " via "}

    for what, with in matches
        StringReplace, done, done, %what%, %with%, All

    return done
}

Titlecase(thisthing){

    content := thisthing

    StringUpper, content, content, T
    content := SubStr(content, 1, 2) . SomeLower(SubStr(content, 3))

    return content
}

UpperCase(thisthing){

    content := thisthing

    StringUpper, content, content

    return content
}

LowerCase(thisthing){

    content := thisthing

    StringLower, content, content

    return content
}

; To extend this setup, add a new menu item, add a case to the Switch statement to handle that menu item, and optionally add additional logic that should be executed when that item is selected from the right-click menu.
; Alternatively, create a whole new menu and trigger it some other way (like Ctrl + Right Click instead of/in addition to Alt + Right Click). 
