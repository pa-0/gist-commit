/*
[wrap list]
(  =  (TXT)
`[ =  [TXT]
{  =  {TXT}
<  =  <TXT>
>  =  >TXT<

a  =   /`*TXT*`/
h  = <!-- TXT -->
k  = <kbd>TXT</kbd>
m  =  ``` TXT ```
p  = '''' TXT ''''

[settings]
select_after = true
input_limit  = 1
delete_limit = 2
*/

#noEnv
#singleInstance, force
sendMode input

iniRead, select_after, % a_lineFile, settings, select_after
iniRead, input_limit,  % a_lineFile, settings, input_limit
iniRead, delete_limit, % a_lineFile, settings, delete_limit

iniRead, ini_section, % a_lineFile, wrap list    ; save wraps to variables
sort, ini_section, F long_lines_first_w
stringReplace, ini_section, ini_section, % "/``*", % "/*", all    ; remove literals
stringReplace, ini_section, ini_section, % "*``/", % "*/", all
loop, parse, % ini_section, `n, `r
    {
    occurrence := (inStr(a_loopField, "=", , 1) = 1) ? ("L2") : ("")  ; (if key name is the equals symbol, then L2)
    stringGetPos, pos, a_loopField, =, % occurrence
    stringMid, ini_value, a_loopField, pos + 2
    stringMid, ini_key, a_loopField, pos, , L
    ini_key   := trim(ini_key)
    ini_value := trim(ini_value)
    if (ini_key = "```;") or (ini_key = "``[")    ; remove literals
        stringTrimLeft, ini_key, ini_key, 1
    asc := asc(ini_key)    ; convert key character to key number
    %asc% := ini_value
    wrap_list .= (wrap_list = "" ? "":"`n") . ini_value
    }
ini_section := ""

return ; end of auto-execute ---------------------------------------------------



!w:: goSub, select_wrap
!+w::goSub, repeat_last_wrap


select_wrap:
toolTip, text wrap . . .
repeat_last_wrap:
selected := selected_text_w()
if (a_thisLabel = "select_wrap")
    {
    input, key, L%input_limit% T5, {delete}{d}{enter}{esc}
    key := (key = "") ? strReplace(errorLevel, "EndKey:", "") : key
    key := (key = "Escape") ? strReplace(key, "Escape", "") : key
    asc := asc(key)
    this_wrap := %asc%    ; get wrap stored in key number
    }

if (key = "delete") or (key = "d")
    goSub, remove_wrap
else if (errorLevel != "Timeout") and if (key != "")
    {
    if (this_wrap)
        split_wrap(this_wrap, l_wrap, r_wrap)
    else
        {
        l_wrap := key
        r_wrap := key
        if (strLen(key) > 1)
            {
            reversed_string := ""
            loop, parse, key
                reversed_string := a_loopField . reversed_string
            r_wrap := reversed_string
            }
        }
    paste_text_w(l_wrap . selected . r_wrap)
    }
toolTip, ; close
return


remove_wrap:
new_string := ""
loop, parse, % wrap_list, `n, `r    ; figure out which wrap is being used
    {
    split_wrap(a_loopField, l_wrap, r_wrap)
    if inStr(selected, l_wrap) and inStr(selected, r_wrap)
        {
        l_len  := strLen(l_wrap)    ; length of characters
        r_len  := strLen(r_wrap)
        l_string := subStr(selected, 1, l_len)    ; take same length from the string
        r_string := subStr(selected, 1 - r_len, r_len)
        if (l_wrap = l_string) and (r_wrap = r_string)    ; match found on both sides
            {
            new_string := subStr(selected, l_len + 1, strLen(selected) - (l_len + r_len))
            break
            }
        }
    }
if (new_string = "")    ; check for matching character on each side
    {
    tmp_string := selected
    loop, % delete_limit
        {
        left_char := subStr(tmp_string, 1, 1)
        right_char := subStr(tmp_string, 0, 1)
        if (left_char = right_char) and regExMatch(left_char, "[^a-zA-Z0-9]") ; if match and not alphanumeric
            tmp_string := subStr(tmp_string, 2, strLen(tmp_string) - 2)       ; remove both sides
        else break
        }
    if (tmp_string != selected)    ; if something changed
        new_string := tmp_string
    }
if (new_string)
    paste_text_w(new_string)
return


long_lines_first_w(line_a, line_b, offset) {
    if strLen(line_b) != strLen(line_a)
        return strLen(line_b) - strLen(line_a)
    return -offset
}


selected_text_w() {
    global save_clipboard
    save_clipboard := clipboardAll
    clipboard := ""
    send ^{c}
    clipWait, 0.1
    if clipboard is not space
        return clipboard
}


paste_text_w(string) {
    global
    clipboard := string
    send ^{v}
    sleep 200
    if (selected = "")
        send % "{left " strLen(r_wrap) "}"    ; move caret between characters
    else if (select_after = "true")
        {
        if (a_thisLabel = "remove_wrap")      ; select whole string
            send % "{left " strLen(string) "}+{right " strLen(string) "}"
        else
            {
            stringGetPos, pos, string, % selected    ; select original selection
            send % "{left " (strLen(string) - pos) "}+{right " strLen(selected) "}"
            }
        }
    sleep 300
    clipboard := save_clipboard
}


split_wrap(wrap_text, byRef l_wrap, byRef r_wrap) {
    stringGetPos, pos, wrap_text, TXT
    stringMid, l_wrap, wrap_text, pos, , L
    stringMid, r_wrap, wrap_text, pos + 4
}

/*
[script info]
version     = 0.4
description = wrap selected text in %symbols%
author      = davebrny
source      = https://gist.github.com/davebrny/cd98cb10d4c944b065fda67b707cfd0b
*/