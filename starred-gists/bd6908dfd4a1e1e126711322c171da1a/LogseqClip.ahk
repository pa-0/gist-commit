/*
[script info]
version     = 0.1
description = Based on basic web clipper for dynalist.io
author      = Kenneth Aar, Based on davebrnys work
source      = https://gist.github.com/kennethaar/4298c53f481b7047a2aeb133da97b6a1
*/

#noEnv
#persistent
#singleInstance, force
sendMode input
    ; tray menu
if !fileExist(a_scriptDir "\dynaclip.ico")    ; download favicon
    urlDownloadToFile, https://dynalist.io/favicon.ico, % a_scriptDir "\dynaclip.ico"
menu, tray, icon, % a_scriptDir "\dynaclip.ico"
menu, tray, add,
menu, tray, add, Start with Windows, start_with_windows
menu, tray, % fileExist(a_startup "\dynaclip.lnk") ? ("check") : ("unCheck"), Start with Windows
    ; create window groups
groupAdd, dynaclip, ahk_exe Dynalist.exe  ; desktop app
groupAdd, dynaclip, ahk_exe chrome.exe    ; browsers
groupAdd, dynaclip, ahk_exe firefox.exe
groupAdd, dynaclip, Microsoft Edge ahk_exe ApplicationFrameHost.exe
    ; set hotkey
hotkey, ifWinActive, ahk_group dynaclip
hotkey, !d, dynaclip_label
hotkey, ifWinActive,
return ; end of auto-execute ----------





dynaclip_label:
winGetTitle, title, a
if inStr(title, "- Dynalist") and !inStr(title, "- Dynalist Forum")
     goSub, show_menu
else goSub, get_details
return



get_details:
clipboard("/save")
selected_text := ""
selected_text := clipboard("/selected")
send ^{l}    ; select address bar
sleep 100
url := clipboard("/selected")
clipboard("/restore")
if (url = "")
    return
send {right}    ; deselect address bar

title_list := ""    ; make a list of page title combinations
stringGetPos, pos, title, -, R1    ; remove browser name
stringMid, title, title, pos - 1, , L
tmp_title := title
stringReplace, tmp_title, tmp_title, % " - ", |, all
stringSplit, split, tmp_title, |
loop, % (split0 - 1)
    {
    this_split := trim(split%a_index%)
    title_list .= this_split "`n"
    next_index := a_index + 1
    next_split := trim(split%next_index%)
    if !inStr(title_list, next_split)
        title_list .= next_split "`n"
    if (title != this_split " | " next_split)
        title_list .= this_split " - " next_split "`n"
    }
if !inStr(title_list, title)
    title_list .= title
title_list := rTrim(title_list, "`r`n")
return



show_menu:
if (title_list = "")
    {
    trayTip, no details saved yet
    return
    }
clipboard("/save")
selected := ""
selected := clipboard("/selected")
clipboard("/restore")

menu("links", 0)    ; add to menu
menu("---")
if (selected != "")
    menu("[" selected "](`%url`%)")
loop, parse, % title_list, `n, `r
    menu("[" a_loopField "](`%url`%)")
menu(url)
menu("---")

menu("title:", 0)
menu("---")
loop, parse, % title_list, `n
    menu(a_loopField)

if (selected_text != "")
    {
    menu("---")
    menu("text:", 0)
    menu("---")
    if (strLen(selected_text) > 60) or inStr(selected_text, "`n")
         menu(">`%selected text`%<")
    else menu(selected_text)
    }

menu, dynaclip, show
menu, dynaclip, delete
return



menu(item, disable="") {
    if (item = "---")
        item := "", label := ""
    menu, dynaclip, add, % item, dynaclip_add
    if (disable != "")
        menu, dynaclip, disable, % item
}



dynaclip_add:
stringReplace, this_menu, a_thisMenuItem, `%url`%, % url
stringReplace, this_menu, this_menu, >`%selected text`%<, % selected_text
clipboard("/save")
clipboard := this_menu
clipboard("/paste")
clipboard("/restore")
return



clipboard(string="") {
    static clipboard_r
    if (string = "/save")
        clipboard_r := clipboardAll
    else if (string = "/restore")
        {
        clipboard := clipboard_r
        clipboard_r := ""
        }
    else if (string = "/selected")
        {
        clipboard := ""
        send ^{c}
        clipWait, 0.3
        return clipboard
        }
    else if (string = "/paste")
        {
        send, ^{v}
        sleep 100
        }
    else if (string = "/clear") or (string = "")
        clipboard := ""
    else
        clipboard := string
}



start_with_windows:    ; tray menu label
if fileExist(a_startup "\dynaclip.lnk")
    fileDelete, % a_startup "\dynaclip.lnk"
else fileCreateShortcut, % a_scriptFullPath, % a_startup "\dynaclip.lnk", , , , , % a_scriptDir "\dynaclip.ico"
menu, tray, % fileExist(a_startup "\dynaclip.lnk") ? ("check") : ("unCheck"), Start with Windows
return