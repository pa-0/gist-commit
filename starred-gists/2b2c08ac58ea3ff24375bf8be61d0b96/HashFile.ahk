
; Version: 2023.04.20.1
; Usages and examples: https://redd.it/m0kzdy

; Configuration ↓

wide := true ; Display the full hashes

; Enables/disabled algorithms
use := {}
use.MD2 := false
use.MD4 := false
use.MD5 := true
use.SHA1 := true
use.SHA256 := true
use.SHA384 := false
use.SHA512 := false

useLower := true ; Hashes in lowercase

; Configuration ↑

;
; Do not edit beyond this point
;

; Some speed-related settings
ListLines Off
SetBatchLines -1
Process Priority,, High

/* A user reported that for some (unknown) reason in one of his drives, the file
being sent to be hashed threw the "No file was selected" message if the filename
contained spaces, this fixes the issue even when is not supposed to happen.
*/
if (A_Args.Count() > 1) {
    file := ""
    for _, arg in A_Args
        file .= arg " "
    A_Args[1] := Trim(file)
}

; Verify if a file (not a directory) was sent
if (FileExist(A_Args[1]) ~= "^$|D") {
    MsgBox 0x40010, Error, No file was selected.
    ExitApp 1
}

/* To avoid issues with spaces the shell works with files in the old 8.3 format,
this expands it to a full long path.
*/
loop Files, % A_Args[1]
    A_Args[1] := A_LoopFileLongPath

; Super-globals to avoid declaring global usage
global RadioGroup := "", RefValue, CurrentHash := 0, AlgData := [], AlgDataCount

/* The map of the algorithms it's created in the index zero given that AHK uses
1-based arrays. It has the pertinent data for the GUI to display and stored.
*/
AlgData[0] := []
AlgData[0].Push({ name: "md2", active: false, len: -1, hash: ""})
AlgData[0].Push({ name: "md4", active: false, len: -1, hash: ""})
AlgData[0].Push({ name: "md5", active: false, len: 32, hash: ""})
AlgData[0].Push({ name: "sha1", active: false, len: 40, hash: ""})
AlgData[0].Push({ name: "sha256", active: false, len: 64, hash: ""})
AlgData[0].Push({ name: "sha384", active: false, len: 96, hash: ""})
AlgData[0].Push({ name: "sha512", active: false, len: 128, hash: ""})

/* Loop through the selected algorithms, copying the objects inside the 0-index
to a consecutive index, is always a good measure to delete what's not needed.
*/
for _, active in use {
    if (active)
        AlgData.Push(AlgData[0, A_Index]) ; Copying an object from [0]
}
AlgData.Delete(0) ; Delete the map to recover memory.
AlgDataCount := AlgData.Count()

init := false
clipHash := ParseClipboard() ; Checking the clipboard for a hash-like string.

; New GUI, fixed-width font.
Gui New, AlwaysOnTop ToolWindow
Gui Font, q5 s10, Consolas

/* In order to work with Radios as a group, only the first one created needs to
have the a variable assigned, all subsequent radios created belong to the group.

This is the variable for the radios, it will be used on the first iteration of -
the `for` loop and it will be cleared (at the end of the first iteration).
*/
v := " vRadioGroup"

for i, alg in AlgData {
    /* It uses the properties in the map. `alg.active` is used to check the
    radio and provide visual feedback of which hash is in display.
    */
    isChecked := (alg.active ? " Checked" : "")
    Gui Add, Radio, % "gRadioChanged h20" isChecked v, % alg.name ":"
    v := ""
}
Gui Add, Text, h20, Reference:

/* The `newSection` option allows the Gui stacking elements automatically within
another column, same as the variable in the Radio Group it will be used once and
it will be cleared on the first iteration.
*/
newSection := " ys"

for i, alg in AlgData {
    /* The variable names of the Edits matches their algorithm counterpart,
    which is consecutive in order to be able to identify the algorithm when
    updating the hash / showing the tooltip.

    For them to have a consistent width are filled with spaces, to later get
    the last Edit (will be the longest) and update the width of all others.
    */
    val := Format("{: " (wide ? alg.len : 21) "}", "")
    Gui Add, Edit, % "ReadOnly -Tabstop h20 vEdit" A_Index newSection, % val
    newSection := ""
}
Gui Add, Edit, Uppercase h20 vRefValue gValidate

/* In wide mode, use the next-to-last size as it will be the biggest and update
all of the Edit boxes with the same size.
*/
if (wide) {
    GuiControlGet largest, Pos, % "Edit" AlgDataCount
    loop % AlgDataCount + 1
        GuiControl Move, % "Edit" A_Index, % "w" largestW + 2
}
/* We don't put the reference value when creating the Edit even if something was
found on the Clipboard because it will alter the sizes, we do now:
*/
GuiControl Text, % "Edit" AlgDataCount + 1, % clipHash

; Display the GUI
Gui Show,, % A_Args[1]

if (init) ; Init might hold an array if a hash is found in the Clipboard.
    GetHash(init*)

if (!wide) ; When clipping the hashes enable a tooltip with the full hash.
    OnMessage(0x200, "MouseMove")

Process Priority,, Normal


return ; End of auto-execute


; Grab the hash from the specified algorithm
GetHash(Alg, Field) {
    global wide, useLower

    /* To put the gui in "stand by": clear the text in the fields, place a -
    "Working" label where appropriate, disable the radio buttons to avoid --
    weird behaviors and disable the reference field.
    */
    loop % AlgDataCount {
        txt := A_Index = Field ? "Working..." : ""
        GuiControl Text, % "Edit" A_Index, % txt
        GuiControl Disable, % "Button" A_Index
    }
    ControlFocus Static1, A
    GuiControl +ReadOnly, % "Edit" AlgDataCount + 1

    if (Alg["hash"] = "") { ; Only hash if we haven't
        hash := Hash_File(A_Args[1], Alg["name"])
        Alg["hash"] := Format("{:" (useLower ? "L" : "U") "}", hash)
    }

    ; Set the hash value
    ControlGet CurrentHash, Hwnd,, % "Edit" Field, % A_Args[1]
    hash := wide ? Alg["hash"] : SubStr(Alg["hash"], 1, 8) " ... "
        . SubStr(Alg["hash"], -7)
    GuiControl Text, % "Edit" Field, % hash

    Validate() ; Validate the hash / update the color of the reference Edit

    loop % AlgDataCount ; Enable the radios
        GuiControl Enable, % "Button" A_Index
    ; Enable the reference field.
    GuiControl -ReadOnly, % "Edit" AlgDataCount + 1
    ControlFocus % "Button" Field, A
}

; Display a ToolTip when hover the current hash.
MouseMove(_wParam, _lParam, _Message, hWnd) {
    if (hWnd != CurrentHash) {
        ToolTip
    } else {
        GuiControlGet varName, Name, % hWnd
        ToolTip % AlgData[SubStr(varName, 5), "hash"]
    }
}

/* Check the clipboard contents for hash-like data, if found, trigger at init a
hashing based on the characteristics of the data found.
*/
ParseClipboard() {
    global init

    txt := Trim(Clipboard, "`t`n`r ")
    if (txt = "")
        return
    if txt is not xdigit
        return
    lengths := ""
    for _, alg in AlgData
        lengths .= alg.len ","
    lengths := RTrim(lengths, ",")
    len := StrLen(txt)
    if len not in % lengths
        return
    for i, alg in AlgData {
        if (alg.len = len) {
            init := [alg, A_Index]
            AlgData[i, "active"] := true
            return Format("{:U}", txt)
        }
    }
}

RadioChanged() { ; Every time a radio changes trigger the proper hashing.
    Gui Submit, NoHide
    for _, alg in AlgData {
        if (RadioGroup = A_Index)
            GetHash(alg, RadioGroup)
    }
}

Validate() { ; Compare the reference value and change the color of the edit.
    Gui Submit, NoHide
    for _, alg in AlgData {
        if (RadioGroup = A_Index) {
            Gui Font, % "c" (alg.hash = RefValue ? "Green" : "Red")
            GuiControl Font, % "Edit" AlgDataCount + 1
            return
        }
    }
}

; Gui Labels
GuiClose:
GuiEscape:
    ExitApp
return

; Standard directives
#NoEnv
#NoTrayIcon
#SingleInstance Ignore

/*

`Hash_File()` is compatible with `LC_CalcFileHash()` from libcrypt.ahk.

If you are already using libcrypt.ahk, you can remove the code below and use the
`LC_CalcFileHash()` instead.

*/

Hash_File(Path, AlgId) {
    out := "ERROR"
        , PROV_RSA_AES := 24
        , CRYPT_VERIFYCONTEXT := 0xF0000000
        ;@ahk-neko-ignore-fn 7 line
        , MD2	 := 0x00008001 ; CALG_MD2
        , MD4	 := 0x00008002 ; CALG_MD4
        , MD5	 := 0x00008003 ; CALG_MD5
        , SHA1   := 0x00008004 ; CALG_SHA1
        , SHA256 := 0x0000800C ; CALG_SHA_256
        , SHA384 := 0x0000800D ; CALG_SHA_384
        , SHA512 := 0x0000800E ; CALG_SHA_512
        , map := StrSplit("0123456789abcdef")
    try {
        if !(oFile := FileOpen(Path, 0x700))
            throw
        oFile.Seek(0)
        if (!DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv := 0, "Ptr", 0, "Ptr", 0, "UInt", PROV_RSA_AES, "UInt", CRYPT_VERIFYCONTEXT))
            throw
        if (!DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", %AlgId%, "UInt", 0, "UInt", 0, "Ptr*", hHash := 0))
            throw
        VarSetCapacity(pbData, 0x4000000, 0) ; 64 Mb
        while (!oFile.AtEOF) {
            cbData := oFile.RawRead(&pbData, 0x4000000)
            if (!DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", &pbData, "UInt", cbData, "UInt", 0))
                throw
        }
        if (!DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", HashLen := 0, "UInt", 0))
            throw
        VarSetCapacity(Hash, HashLen)
        if (!DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &Hash, "UInt*", HashLen, "UInt", 0))
            throw
        out := ""
        loop % HashLen {
            val := NumGet(Hash, A_Index - 1, "UChar")
            out .= map[(val >> 0x4) + 1] map[(val & 0xF) + 1]
        }
    }
    if (hHash)
        DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
    if (hProv)
        DllCall("advapi32\CryPtReleaseContext", "Ptr", hProv, "UInt", 0)
    return out
}
