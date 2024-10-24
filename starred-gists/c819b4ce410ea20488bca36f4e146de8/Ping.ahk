
; Version: 2022.11.17.1
; https://gist.github.com/75a33c3aab9be7c343a1916c43c64339

Ping(Address, ByRef Result := "", Timeout := 1000) {
    static lastAddr := "", ip := "", pAddr := 0, hIcmp := 0
    if (Address != lastAddr) {
        pAddr := Ping_IPAddress(Address, ip)
        lastAddr := Address
    }
    if (!hIcmp) {
        hIcmp := DllCall("iphlpapi\IcmpCreateFile")
        if (!hIcmp) {
            ErrorLevel := "IcmpCreateFile() failed to open a port!"
            return
        }
    }
    replySize := VarSetCapacity(replyBuffer, 40, 0)
    replied := DllCall("iphlpapi\IcmpSendEcho", "Ptr",hIcmp, "Ptr",pAddr, "Ptr",0
        , "UInt",0, "Ptr",0, "Ptr",&replyBuffer, "UInt",replySize, "UInt",Timeout)
    if (!replied) {
        ErrorLevel := "IcmpSendEcho() failed with code: " A_LastError
        return
    }
    rtt := NumGet(replyBuffer, 8, "UInt")
    Result := {"InAddr":Address, "IPAddr":ip, "RTTime":rtt}
    return rtt
}

Ping_IPAddress(Address, ByRef IP := "") {
    static size := 434 + (A_PtrSize - 2) + A_PtrSize
        , offset := (2 * A_PtrSize) + 4 + (A_PtrSize - 4)
        , _ := DllCall("Kernel32\LoadLibrary", "Str","iphlpapi.dll")
    VarSetCapacity(WSADATA, size, 0)
    err := DllCall("Ws2_32\WSAStartup", "Int",0x0202, "Ptr",&WSADATA)
    if (err) {
        ErrorLevel := "WSAStartup() failed with code: " err
        return
    }
    if (RegExMatch(Address, "\D+")) {
        HOSTENT := DllCall("Ws2_32\gethostbyname", "AStr",Address)
        if (!HOSTENT) {
            err := DllCall("Ws2_32\WSAGetLastError", "Int")
            DllCall("Ws2_32\WSACleanup")
            ErrorLevel := "gethostbyname() failed with code: " err
            return false
        }
        pList := NumGet(HOSTENT + 0, offset, "Ptr")
        lAddr := NumGet(pList + 0, 0, "Ptr")
        pAddr := NumGet(lAddr + 0, 0, "Int")
        Address := DllCall("Ws2_32\inet_ntoa", "Int",pAddr)
        Address := StrGet(Address, "CP0")
    }
    IP := Address
    pAddr := DllCall("Ws2_32\inet_addr", "AStr",Address)
    DllCall("Ws2_32\WSACleanup")
    if (pAddr = 0xFFFFFFFF) {
        ErrorLevel := "inet_addr() failed for address: " Address
        return
    }
    return pAddr
}
