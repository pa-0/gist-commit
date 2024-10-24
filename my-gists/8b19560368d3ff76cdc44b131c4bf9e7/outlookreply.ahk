; Scripting replies in Outlook with AutoHotkey v2
;
; Hit Alt + x (or !x) to create a reply email (template) with
; salutation to sender's First Name from selected / opened
; email in Microsoft Outlook, which looks like this:
;
; Hello <FirstName>,
;
; Thank you for your email.
;
; <Signature appears here, if set-up in Outlook>
;
#Requires AutoHotkey >=2.0

!x::
{
    ; Get the active email item
    ol := ComObjActive("Outlook.Application").ActiveExplorer().Selection.Item(1)
    
    ; Check if the item is valid and get the sender's name
    if (IsObject(ol)) {
        senderName := ol.SenderName
        ; MsgBox "Sender Name: " . senderName ; Debug message to check senderName
        
        ; Initialize variables
        firstName := ""
        
        ; Check if the name is in "Lastname, Firstname" format
        commaPos := InStr(senderName, ",")
        if (commaPos > 0) {
            ; Extract first name after the comma
            firstName := SubStr(senderName, commaPos + 2) ; Skip ", " (comma and space)
        } else {
            ; Handle "Firstname Lastname" format
            spacePos := InStr(senderName, " ")
            if (spacePos > 0) {
                firstName := SubStr(senderName, 1, spacePos - 1) ; Extract first name before the space
            }
        }
        
        ;; Display the extracted first name
        ; MsgBox "Extracted First Name: " . firstName
        
        ; Send the reply with the template
        Send("^r") ; Open reply
        Sleep(10) ; Wait for the reply window to open
        Send("Hello " . firstName . ",{Enter 2}Thank you for your email.{Enter 2}")
    } else {
        MsgBox "No valid Outlook item found."
    }
}