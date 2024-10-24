#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Array of URLs you want to open
urlA        :=  ["https://example.com"
                ,"https://example2.com"
                ,"https://example3.com"
                ,"https://example4.com"]

; Build list of urls on one line
urlList     := ""
for index, value in urlA
    urlList .= ((A_Index = 1) ? "" : " ") . value
return

; Open URLs in already opened Chrome window
^!m::Run, % "chrome.exe " urlList

; Make a new Chrome window and open URLs there
^!n::Run, % "chrome.exe --new-window " urlList