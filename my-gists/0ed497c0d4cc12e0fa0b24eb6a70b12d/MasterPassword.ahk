
; Version: 2023.01.06.1
; Information: https://redd.it/1051mkc

MasterPassword(Path) {
    static decrypted := ""
    if (!Path)
        return decrypted := ""
    if (decrypted)
        return decrypted
    try
        FileRead data, % Path
    catch
        throw Exception("Couldn't read password file.", -1, Path)
    data := StrSplit(data, "|")
    encrypted := data[1]
    iterations := data[2]
    loop 3 {
        InputBox key, Encryption Key:,, Hide, 200, 100,,, Locale
        if (ErrorLevel)
            Exit
        if (!key)
            continue
        try {
            salt := MasterPassword_Salt(key)
            key := Crypt.Hash.PBKDF2("SHA512", key, salt, iterations, 512)
            decrypted := Crypt.Decrypt.String("AES", "CBC", encrypted, key)
            return decrypted
        }
    }
    MsgBox 0x40010, Error, Password couldn't be decrypted.
    Exit
}

; Options := {}
; Options.Inactive := int  ; In minutes
; Options.Lid      := bool ; On lid close
; Options.Lock     := bool ; On lock screen
; Options.Sleep    := bool ; On system sleep
MasterPassword_Clear(Options) {
    static timer := "", a := "", b := ""
    if (IsObject(timer)) {
        SetTimer % timer, Delete
        timer := ""
    }
    if (IsObject(a))
        OnMessage(0x0218, a, 0), a := ""
    if (IsObject(b))
        OnMessage(0x02B1, b, 0), b := ""
    if (!IsObject(Options))
        return
    if (Options.Inactive ~= "^\d+$") {
        if (Options.Inactive) {
            ms := 1000 * 60 * Options.Inactive
            timer := Func("MasterPassword_Timer").Bind(ms)
            SetTimer % timer, % 1000 * 10
        }
    }
    ; WM_POWERBROADCAST
    if (Options.Lid = true || Options.Sleep = true) {
        VarSetCapacity(GUID_LIDSWITCH_STATE_CHANGE, 16, 0)
        NumPut(0xBA3E0F4D,GUID_LIDSWITCH_STATE_CHANGE, 0, "UInt")
        NumPut(0x4094B817,GUID_LIDSWITCH_STATE_CHANGE, 4, "UInt")
        NumPut(0x63D5D1A2,GUID_LIDSWITCH_STATE_CHANGE, 8, "UInt")
        NumPut(0xF3A0E679,GUID_LIDSWITCH_STATE_CHANGE, 12, "UInt")
        DllCall("User32\RegisterPowerSettingNotification"
            , "UInt",A_ScriptHwnd
            , "Ptr",&GUID_LIDSWITCH_STATE_CHANGE
            , "UInt",0)
        if (IsObject(a)) {
            OnMessage(0x0218, a, 0)
            a := ""
        }
        a := Func("MasterPassword_Monitor").Bind("A")
        OnMessage(0x0218, a)
    }
    ; WM_WTSSESSION_CHANGE
    if (Options.Lock = true) {
        DllCall("Wtsapi32\WTSRegisterSessionNotification"
            , "Ptr",A_ScriptHwnd
            , "UInt",1)
        if (IsObject(b)) {
            OnMessage(0x02B1, b, 0)
            b := ""
        }
        b := Func("MasterPassword_Monitor").Bind("B")
        OnMessage(0x02B1, b)
    }
}

MasterPassword_Create(Pass, Path) {
    ; Dynamically generated salt
    salt := MasterPassword_Salt(Pass)
    ; Calculate iterations per second
    tc := A_TickCount, iterations := 100000
    Crypt.Hash.PBKDF2("SHA512", Pass, salt, iterations, 512)
    elapsed := A_TickCount - tc
    iterations := Ceil(1000 * iterations / elapsed)
    ; Derive key
    key := Crypt.Hash.PBKDF2("SHA512", Pass, salt, iterations, 512)
    ; Encrypt password with AES CBC
    encrypted := Crypt.Encrypt.String("AES", "CBC", Pass, key)
    ; Save it alongside the number of number of iterations for the key
    if (!FileOpen(Path, 0x1, "CP1252").Write(encrypted "|" iterations))
        throw Exception("Couldn't write to " Path, -1)
}

MasterPassword_Monitor(Type, wParam, lParam, Msg) {
    if (Type = "A" && Msg = 0x0218 && wParam = 0x4) ; Lid/Sleep
    || (Type = "B" && Msg = 0x02B1 && wParam = 0x7) ; Lock
        MasterPassword("")
}

MasterPassword_Salt(String) {
    strLen := StrLen(String)
    seed := DllCall("Ntdll\RtlComputeCrc32"
        , "Ptr",0
        , "AStr",String
        , "UInt",strLen
        , "UInt")
    Random ,, % seed
    salt := ""
    loop % strLen {
        Random r, 0x20, 0xFFFF
        salt .= Chr(r)
    }
    Random ,, % A_Now
    salt := Crypt.Hash.String("SHA512", salt)
    return salt
}

MasterPassword_Timer(ms) {
    if (A_TimeIdle >= ms)
        MasterPassword("")
}
