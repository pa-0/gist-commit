
; Clear on sleep:
MasterPassword_Clear({"Sleep": true})

return ; End of auto-execute


; To create a new encrypted file containing your password
^!c::
    InputBox passwd, Master Password:,,, 200, 100,,, Locale
    if (!passwd)
        return
    MasterPassword_Create(passwd, A_AppData "\master.dat")
return

; To type your password after successfully decrypting it
^!p::       ; Via hotkey
:*X:pass\:: ; Via hotstring
    SetKeyDelay 30
    SendEvent % "{Text}" MasterPassword(A_AppData "\master.dat")
return

#Include %A_LineFile%\..\Crypt.ahk
; https://github.com/jNizM/AHK_CNG

#Include %A_LineFile%\..\MasterPassword.ahk
