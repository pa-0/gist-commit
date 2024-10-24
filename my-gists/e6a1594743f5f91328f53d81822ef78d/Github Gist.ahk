;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
;~ #Include C:\Users\Joe\DropBox\Progs\AutoHotkey_L\Lib\Default_Settings.ahk
;~ https://gist.github.com/JoeGlines
#SingleInstance,Force
IniRead,Token,B:\Progs\AutoHotkey_L\AutoRun\Creds.ini,Credentials,Token ;Get your own Token and put in here
if (!Token){
	MsgBox You need to provide the token to your GIT
	Exitapp
}

GitName:="JoeGlines" ;Add your name here
if (!GitName){
	MsgBox You need to provide the name of your GIT...
	Exitapp
}

;********************Try and Get the name of the script***********************************
WinGetTitle, ActiveWindow , A ;Get active title
RegExMatch(ActiveWindow,"(.*\\)?(.*)\.ahk",file) ;Try and isolate the file path with RegEx
NNE:= file2 ;Store in NNE variable (Name No Extension)
Clipboard:=""
Send ^c
ClipWait, 1
If ErrorLevel { ;Added errorLevel checking		
	Clipboard:=ClipBack ;Restore Clipboard
	MsgBox, No text was sent to clipboard
	Return 
}

gui, add,text,,Name of file  (don't add .ahk)
gui, add,edit,w200 vFileName,%NNE% ;provide suggested filename but let them change it
gui, add,text,,Description
gui, add,edit,w200 vDescr ;Type in description 
gui, Add, Button, default, Gist ;Create button
gui, show, autosize
return

GuiClose:
ButtonGist:
Gui, Submit  ; Save the input from the user to each control's associated variable.
Filename:= (SubStr(filename,-3)=".ahk")?(SubStr(Filename,1,StrLen(Filename)-4)):Filename ;just in case they end it with .ahk
Body:=Jxon_Dump({content:Clipboard}) ;need to encode it 
Data={"description": "%Descr%","public": true,"files": {"%FileName%.ahk": %Body%}} ;build data for post havnig double quotes
Obj:=ParseJSON(Send(Token,"https://api.github.com/gists","POST",Data)) ;make post and return information about it
Clipboard:="Use the following for a webpage post:`n<script src='https://gist.github.com/" GitName "/"(SubStr(obj.url,Instr(obj.url,"/",,0)+1))".js'></script>`n`nYou can get the code here: " obj.html_url
WinGetTitle, ActiveWindow , A ;Get active title

if (instr(ActiveWindow,"AHK Studio"))
	DebugWindow("The clipboard now has:`n" clipboard,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0) ;Display results in Debug window
Else 
	MsgBox, ,GIST Post,% "The clipboard now has:`n`n" clipboard,20

ExitApp
return

Send(Token,URL:="",Verb:="",Data:=""){
	static WebRequest:=ComObjCreate("WinHttp.WinHttpRequest.5.1") ;Create COM object
	WebRequest.Open(Verb,URL) ;Open connection
	WebRequest.SetRequestHeader("Authorization","token " Token,0)
	WebRequest.SetRequestHeader("Content-Type","application/json")
	WebRequest.Send(Data) ;Send Payload
	return WebRequest.ResponseText
}


;********************Required Functions***********************************

;*************Jxon by CoCo  https://github.com/cocobelgica/AutoHotkey-JSON ******************************************
Jxon_Load(ByRef src, args*)
{
	static q := Chr(34)

	key := "", is_key := false
	stack := [ tree := [] ]
	is_arr := { (tree): 1 }
	next := q . "{[01234567890-tfn"
	pos := 0
	while ( (ch := SubStr(src, ++pos, 1)) != "" )
	{
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true)
		{
			ln := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}

		is_array := is_arr[obj := stack[1]]

		if i := InStr("{[", ch)
		{
			val := (proto := args[i]) ? new proto : {}
			is_array? ObjPush(obj, val) : obj[key] := val
			ObjInsertAt(stack, 1, val)
			
			is_arr[val] := !(is_key := ch == "{")
			next := q . (is_key ? "}" : "{[]0123456789-tfn")
		}

		else if InStr("}]", ch)
		{
			ObjRemoveAt(stack, 1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}

		else if InStr(",:", ch)
		{
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q . "{[0123456789-tfn"
		}

		else ; string | number | true | false | null
		{
			if (ch == q) ; string
			{
				i := pos
				while i := InStr(src, q,, i+1)
				{
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					static end := A_AhkVersion<"2" ? 0 : -1
					if (SubStr(val, end) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				  val := StrReplace(val,    "\/",  "/")
				, val := StrReplace(val, "\" . q,    q)
				, val := StrReplace(val,    "\b", "`b")
				, val := StrReplace(val,    "\f", "`f")
				, val := StrReplace(val,    "\n", "`n")
				, val := StrReplace(val,    "\r", "`r")
				, val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1)
				{
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					; \uXXXX - JSON unicode escape sequence
					xxxx := Abs("0x" . SubStr(val, i+2, 4))
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}

				if is_key
				{
					key := val, next := ":"
					continue
				}
			}

			else ; number | true | false | null
			{
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
			
			; For numerical values, numerify integers and keep floats as is.
			; I'm not yet sure if I should numerify floats in v2.0-a ...
				static number := "number", integer := "integer"
				if val is %number%
				{
					if val is %integer%
						val += 0
				}
			; in v1.1, true,false,A_PtrSize,A_IsUnicode,A_Index,A_EventInfo,
			; SOMETIMES return strings due to certain optimizations. Since it
			; is just 'SOMETIMES', numerify to be consistent w/ v2.0-a
				else if (val == "true" || val == "false")
					val := %value% + 0
			; AHK_H has built-in null, can't do 'val := %value%' where value == "null"
			; as it would raise an exception in AHK_H(overriding built-in var)
				else if (val == "null")
					val := ""
			; any other values are invalid, continue to trigger error
				else if (pos--, next := "#")
					continue
				
				pos += i-1
			}
			
			is_array? ObjPush(obj, val) : obj[key] := val
			next := obj==tree ? "" : is_array ? ",]" : ",}"
		}
	}

	return tree[1]
}

Jxon_Dump(obj, indent:="", lvl:=1)
{
	static q := Chr(34)

	if IsObject(obj)
	{
		static Type := Func("Type")
		if Type ? (Type.Call(obj) != "Object") : (ObjGetCapacity(obj) == "")
			throw Exception("Object type not supported.", -1, Format("<Object at 0x{:p}>", &obj))

		prefix := SubStr(A_ThisFunc, 1, InStr(A_ThisFunc, ".",, 0))
		fn_t := prefix "Jxon_True",  obj_t := this ? %fn_t%(this) : %fn_t%()
		fn_f := prefix "Jxon_False", obj_f := this ? %fn_f%(this) : %fn_f%()

		if (&obj == &obj_t)
			return "true"
		else if (&obj == &obj_f)
			return "false"

		is_array := 0
		for k in obj
			is_array := k == A_Index
		until !is_array

		static integer := "integer"
		if indent is %integer%
		{
			if (indent < 0)
				throw Exception("Indent parameter must be a postive integer.", -1, indent)
			spaces := indent, indent := ""
			Loop % spaces
				indent .= " "
		}
		indt := ""
		Loop, % indent ? lvl : 0
			indt .= indent

		this_fn := this ? Func(A_ThisFunc).Bind(this) : A_ThisFunc
		lvl += 1, out := "" ; Make #Warn happy
		for k, v in obj
		{
			if IsObject(k) || (k == "")
				throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", &obj) : "<blank>")
			
			if !is_array
				out .= ( ObjGetCapacity([k], 1) ? %this_fn%(k) : q . k . q ) ;// key
				    .  ( indent ? ": " : ":" ) ; token + padding
			out .= %this_fn%(v, indent, lvl) ; value
			    .  ( indent ? ",`n" . indt : "," ) ; token + indent
		}

		if (out != "")
		{
			out := Trim(out, ",`n" . indent)
			if (indent != "")
				out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
		}
		
		return is_array ? "[" . out . "]" : "{" . out . "}"
	}

	; Number
	else if (ObjGetCapacity([obj], 1) == "")
		return obj

	; String (null -> not supported by AHK)
	if (obj != "")
	{
		  obj := StrReplace(obj,  "\",    "\\")
		, obj := StrReplace(obj,  "/",    "\/")
		, obj := StrReplace(obj,    q, "\" . q)
		, obj := StrReplace(obj, "`b",    "\b")
		, obj := StrReplace(obj, "`f",    "\f")
		, obj := StrReplace(obj, "`n",    "\n")
		, obj := StrReplace(obj, "`r",    "\r")
		, obj := StrReplace(obj, "`t",    "\t")

		static needle := (A_AhkVersion<"2" ? "O)" : "") . "[^\x20-\x7e]"
		while RegExMatch(obj, needle, m)
			obj := StrReplace(obj, m[0], Format("\u{:04X}", Ord(m[0])))
	}
	
	return q . obj . q
}

Jxon_True()
{
	static obj := {}
	return obj
}

Jxon_False()
{
	static obj := {}
	return obj
}


;********************ParseJSON***********************************
ParseJSON(jsonStr){
	static SC:=ComObjCreate("ScriptControl"),C:=Chr(125)
	SC.Language:="JScript",ComObjError(0),SC.ExecuteStatement("function arrangeForAhkTraversing(obj){if(obj instanceof Array){for(var i=0; i<obj.length; ++i)obj[i]=arrangeForAhkTraversing(obj[i]);return ['array',obj];" C "else if(obj instanceof Object){var keys=[],values=[];for(var key in obj){keys.push(key);values.push(arrangeForAhkTraversing(obj[key]));" C "return ['object',[keys,values]];" C "else return [typeof obj,obj];" C ";obj=" jsonStr)
	return convertJScriptObjToAhks(SC.Eval("arrangeForAhkTraversing(obj)"))
}ConvertJScriptObjToAhks(JSObj){
	if(JSObj[0]="Object"){
		Obj:=[],Keys:=JSObj[1][0],Values:=JSObj[1][1]
		while(A_Index<=Keys.length)
			Obj[Keys[A_Index-1]]:=ConvertJScriptObjToAhks(Values[A_Index-1])
		return Obj
	}else if(JSObj[0]="Array"){
		Array:=[]
		while(A_Index<=JSObj[1].length)
			Array.Push(ConvertJScriptObjToAhks(JSObj[1][A_Index-1]))
		return Array
	}else
		return JSObj[1]
}

;********************AHK STudio Debug Window***********************************
DebugWindow(Text,Clear:=0,LineBreak:=0,Sleep:=0,AutoHide:=0,MsgBox:=0){
	x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}"),x.DebugWindow(Text,Clear,LineBreak,Sleep,AutoHide,MsgBox)
}