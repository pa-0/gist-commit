/************************************************************************
 * @description Create an interface that allows users to customize hotkeys. 
 * @file SetHotkeyGui.ahk
 * @link https://github.com/nperovic
 * @author Nikola Perovic
 * @date 2024/04/22
 * @version 1.0.0
 ***********************************************************************/

#Requires AutoHotkey v2
#SingleInstance 

Persistent()

/* Initialize the GUI with default settings */
SetHotkeyGui(0)

/* Bind the F1 key to show the hotkey setting gui */
F1:: SetHotkeyGui()

/* Define the SetHotkeyGui function with an optional Show parameter */
SetHotkeyGui(Show := 1)
{
    /* Declare a default hotkey and a variable for the GUI */
    static defaultHK := "^F1", myGui := ""
    
    /* If the GUI exists and Show is true, show the GUI and exit the function */
    if myGui && Show
        return myGui.Show("AutoSize")

    /* Check if the setting.ini file exists and read the current hotkey; if not, write the default hotkey to the file */
    if !FileExist("setting.ini") || !(currentHK := IniRead("setting.ini", "Section1", "HotKey", ""))
        IniWrite(currentHK := defaultHK, "setting.ini", "Section1", "HotKey")

    /* Register the current hotkey to call the HotkeyCallback function */
    Hotkey(currentHK, HotkeyCallback)

    myGui := Gui(, "Hotkey Setting | " A_ScriptName)
    myGui.Opt("-MinimizeBox -MaximizeBox +AlwaysOnTop")
    myGui.SetFont("s12", "Segoe UI")
    /* Add a text element to display the current hotkey */
    myGui.AddText("vOldHK r1 +0x200", "Current Hotkey: " (myGui.currentHK := currentHK))
    /* Add a hotkey input field initialized with the current hotkey */
    myGui.AddHotkey("vNewHK", currentHK)
    /* Add a submit button and bind the OnClick function to its click event */
    myGui.AddButton("x16 y104 w255 h35", "&Submit").OnEvent("Click", OnClick)
    /* Define an exit function to delete the old hotkey and write the new one to the setting.ini file */
    OnExit((*) => (
        IniDelete("setting.ini", "Section1", "HotKey"),
        IniWrite(myGui["NewHK"].Value, "setting.ini", "Section1", "HotKey")
    ))
    
    /* Define the OnClick function for the submit button */
    OnClick(guictrl, *)
    {
        /* Retrieve the GUI object from the control */
        g   := guictrl.Gui
        /* Format a message displaying the current and new hotkeys */
        msg := Format("
        (
            Current Hotkey: {1} 
            New Hotkey    : {2}
        )", oldHK := g.currentHK, newHK := g["NewHK"].Value)
            
        /* If the old and new hotkeys are the same or the user chooses not to change, hide the GUI */
        if (oldHK = newHK) || ("Yes" != MsgBox(msg, "Change Hotkey Now?", "0x4 Owner" g.hwnd))
            return g.Hide()
    
        /* Turn off the old hotkey */
        Hotkey(oldHK, "Off")
        /* Try to set the new hotkey and handle any exceptions */
        try HotKey(newHK, HotkeyCallback, "On")
        catch 
            /* If setting the new hotkey fails, show a message and re-enable the old hotkey */
            MsgBox("The attempt to assign a new hotkey did not succeed."),
            Hotkey(oldHK, HotkeyCallback, "On")
        else 
            /* If successful, update the tray tip with the new hotkey */
            TrayTip(g["OldHK"].Value := "Current Hotkey: " (oldHK := newHK), "The new hotkey has been set successfully.")
    
        /* Hide the GUI after processing */
        g.Hide()
    }
}

/* Define the HotkeyCallback function when the hotkey is triggered */
HotkeyCallback(hk) => MsgBox(hk)
