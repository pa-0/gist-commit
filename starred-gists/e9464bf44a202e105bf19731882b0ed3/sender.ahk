#Requires AutoHotkey v1.1
#Warn All

; Send a message to non-existent script
Message.Send("Hello World!", "non-existent-script.ahk")
if (ErrorLevel = -1)
    MsgBox 0x40010, Error, Target not found, message wasn't sent.

; Send a message (filtered by receiver's callback)
Message.Send("Hello", "receiver.ahk")
if (ErrorLevel)
    MsgBox 0x40030, Attention!, Message was ignored (too short).

; Send a message (receiver's callback will inform)
Message.Send("Hello World!", "receiver.ahk")

ExitApp

#Include %A_LineFile%\..\Message.ahk
