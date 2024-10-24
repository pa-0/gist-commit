
; Version: 2023.01.19.1
; Usage and examples: https://redd.it/pap3c1

;@Ahk2Exe-IgnoreBegin
d(Arguments*) {
    static gcl := DllCall("GetCommandLine", "Str")
    if (IsObject(Arguments[1])) {
        out := d_Recurse(Arguments[1], 1)
    } else {
        out := ""
        for _,val in Arguments
            out .= (StrLen(val) ? val : "EMPTY") " | "
        len := StrLen(out) - 3
        out := SubStr(out, 1, len)
        out := len > 0 ? out : "EMPTY"
    }
    if (gcl ~= "i) \/Debug(?:=\H+)? .*\Q" A_ScriptName "\E")
        OutputDebug % out "`n"
    else
        MsgBox 0x40040, > Debug, % out
}

d_Recurse(Object, Indent, Level := 1) {
    isArray := Object.Count() = Object.MaxIndex()
    out := (isArray ? "Array" : "Object") "`n"
    chr := Indent = 1 ? A_Tab : A_Space
    out .= d_Repeat(chr, Indent * (Level - 1)) "(`n"
    for key,val in Object {
        out .= d_Repeat(chr, Indent * Level)
        out .= "[" key "] => "
        if (IsObject(val))
            out .= d_Recurse(val, Indent, Level + 1)
        else
            out .= StrLen(val) ? val : "EMPTY"
        out .= "`n"
    }
    out .= d_Repeat(chr, Indent * (Level - 1)) ")"
    return out
}

d_Repeat(String, Times) {
    replace := Format("{: " Times "}", "")
    return StrReplace(replace, " ", String)
}
;@Ahk2Exe-IgnoreEnd

/*@Ahk2Exe-Keep
d(A*){
static _:=d_()
}
d_(){
MsgBox 0x1010,Error,Debug dump(s) in code!
ExitApp 1
}
*/
