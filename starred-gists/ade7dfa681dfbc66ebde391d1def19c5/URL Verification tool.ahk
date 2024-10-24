;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#SingleInstance, Force
#NoEnv
SetBatchLines -1 ;run as fast as possible
;~ DetectHiddenWindows, On
;~ ListLines On ;on helps debug a script
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
Menu, tray, icon, B:\Progs\AutoHotKey_l\Icons\Win\ico_shell32_dll0210.ico, 1 
Menu, Tray, Add, Change ID (Control + I), Change_ID
Browser_Forward::Reload
Browser_Back::
GoSub Change_ID
return

; to do 
; 1) put in loop
; 2) break out root between UAT and ti.com
; 3) compare uat to ti.com
Run_It:
TopCounts:=15  ;control # of top words on page extracted
Wait_For_Server:=2000  ;wait secons for server to respond to ping
gosub Extract_HTML
gosub Site_Catalyst
gosub Word_Count
gosub Import_Excel
IfEqual, verify,1,gosub Verify_href
gosub End
return

Change_ID:
^i::
pwb:=GetIE()
all:=pwb.document.all ;.tags("option") ;.tags("A")
while   (A_Index<=all.length)
	if all[A_Index-1].id ;.options  ;leaving blank means it exists
      ids.=all[A_Index-1].id . "|"
      StringTrimRight, ids, ids, 1

Gui,Add, Button,Default, Submit
Gui,Add, Button,x+20 ,Cancel
Gui,Add, Radio, x+20 vVerify group , Verify URLs
Gui,Add, Radio, Checked  y+10  , Don't Verify URLs
Gui,Add, DropDownList, x6 y+10 w200  vBody_ID , %ids% ;Black|White|Red|Green|Blue
GuiControl,ChooseString, body_id, ls-row-3-col-2 ;Try and select this one by default
Gui Show, h75 w250, Test
ids:="" ;Clear Ids
return

ButtonCancel:
Gui, Destroy
Return

ButtonSubmit:
Gui, Submit
Gui, Destroy
gosub Run_It
return

;*******************************************************
;*********************Webpage**********************************
;*******************************************************
Extract_HTML:
StartTime := A_TickCount ;Get time started to check how long it takes
pwb:=GetIE()
;~ pwb:=setWbCom(name:="",url:="http://www.ti.com/") ;get pointer TI
;~ to do ; give error if ie not running- make sure it is ie running and on page
url:=pwb.locationURL
;**********************get tab title and trim / replace for illegal chars*********************************
Full_Tab_Title:= pwb.Document.title ;getting tab title
StringReplace, Tab_Title, Full_Tab_Title,  - TI.com,, ;trimming  - TI.com as redundant and need to be shorter
Tab_Title:= RegExReplace(Tab_Title, "[#/\\:&\*\?\{<>|\]\.]", "_")  ;replace illegal chars www.autohotkey.com/community/viewtopic.php?f=1&t=13544&hilit=regexreplace
Tab_Title := RegExReplace(Tab_Title, "_+", " ") All  ; replace mutliple _ with space
Tab_Title :=RegExReplace(Tab_Title,".*?-(.*)","$1")
;~ MsgBox,,title, % Tab_Title
StringLeft,Tab_Title,Tab_Title,31 ;trim to first 31 charachters  ;~ MsgBox,,title, % Tab_Title

;*************************Grab just inner framework area******************************
Test_Section:= pwb.document.getElementByID(Body_ID) 
if (Test_Section="") {
 MsgBox % "The ID / element could not be found on this page:`n`n" Tab_Title "`n" url
return
}

;*******************************************************
Tag:="a"  ;what tags looking for.  Should do other than just a?
Test_Section_CT:=Test_Section.all.tags(TAG).length ;count of all tags under above 
msg:="Links=" Test_Section_CT "`t`t" Full_Tab_Title "`t" URL "`r"  ;~ MsgBox,,title, % msg
msg.="Link #`tName`tInnerText`thref`tStatus`tOuterHTML`n"

;**********************wrap line breaks in Innertext with quotes*********************************
loop %Test_Section_CT% {
   Inner_Text:= Test_Section.all.tags(TAG)[A_Index-1].InnerText
Test_Section.all.tags(TAG)[A_Index-1].outerhtml:="<span style='color:blue'>" A_Index . ") </span>" . Test_Section.all.tags(TAG)[A_Index-1].OuterHTML  ;added this line
      IfInString,Inner_Text,`n
      { ;line break in text
         StringReplace, Inner_Text, Inner_Text, `n, , All
         StringReplace, Inner_Text, Inner_Text, `r, (chr10), All
         Run_Search_Replace:=1
      }
;**********************Href-*********************************
   href:= Test_Section.all.tags(TAG)[A_Index-1].href
   name:= Test_Section.all.tags(TAG)[A_Index-1].name

;**********************remove line breaks in HTML *********************************
   Outer_HTML:= Test_Section.all.tags(TAG)[A_Index-1].OuterHTML
      IfInString,Outer_HTML,`n
      {
      StringReplace, Outer_HTML, Outer_HTML, `r`n, , All
      StringReplace, Outer_HTML, Outer_HTML, `n, , All
      StringReplace, Outer_HTML, Outer_HTML, `r, , All
       Outer_HTML:="""" . Outer_HTML . """"
      }
   ;**********************remove tabs*********************************
      IfInString,Outer_HTML,%tab%
      {
      StringReplace, Outer_HTML, Outer_HTML,%A_Tab%, , All
      Outer_HTML:="""" . Outer_HTML . """"
      }
  
   msg.=A_index "`t" name "`t" Inner_Text "`t" href "`t`t" Outer_HTML "`n"
    Line_Break_in_Text= , name=
}
Clipboard:=msg
msg=
SplitPath, url, Page_name, dir, ext, name_no_ext, drive
File_Name:=dir page_name
StringReplace, File_name, File_name, http://,,
StringReplace, File_name, File_name, /,_,,all

FileDelete, %file_name%.html
page:=pwb.document.documentElement.OuterHTML

HTML_page =
( Ltrim Join
<!DOCTYPE html>
<html>
    <head>
        
    </head>
    <body>
   %page%
    </body>
</html>
)
FileAppend, %HTML_page%,%A_ScriptDir%\%file_name%.html,UTF-8
return
;*******************************************************
;**********************Excel*********************************
;**************************************************
Import_Excel:
;~ path:=A_ScriptDir "\" Text_File ;~ MsgBox,,title, % path
Sleep 200
;~ xl:=XL_Start_Get(XL,1) ;WRB is pointer to workbook, Vis=0 for hidden Try=0 for new Excel
try 
{
;~ XL := ComObjActive("Excel.Application") ;handle
XL:=XL_Handle(1) ;XL_Handle(XL,1) ;1=Application 2=Workbook 3=Worksheet
xl.Worksheets.Add().Name := Tab_Title 
} Catch {
XL := ComObjCreate("Excel.Application") ;handle
XL.Visible := 1 ;1=Visible/Default 0=hidden
   sleep, 500
   xl.Workbooks.Add
   Sleep, 200
xl.Worksheets.Add().Name := Tab_Title
}
WinActivate, ahk_class XLMAIN
Sleep 200
XL_Paste2(XL,Dest_RG:="a1",Paste:=1) 
Header_RG:="A1:E2" ;Set header range
;**********************set tab title to reflect page title*********************************
XL.Application.ActiveSheet.Range("B1").value:= Page_Name ;page name for Site Catalyst 
;~ XL_Add_Comment(XL,RG:="b1",Comment:=Content_Group,Vis:=0,Size:=11,Font:="Book Antique",ForeClr:=5)
XL_Insert_Comment(XL,RG:="b1",Comment:=Content_Group,Vis:=0,Size:=11,Font:="Arial",ForeClr:=5)
XL.Application.ActiveSheet.Range("F1").value:= top_words ;page name for Site Catalyst 
XL_Insert_Comment(XL,RG:="F1",Comment:="Top " TopCounts " words on page",Vis:=0,Size:=11,Font:="Book Antique",ForeClr:=5)
XL_Freeze(XL,Row:="2") ;Col A will not include cols which is default so leave out if unwanted
LR:=XL_Last_Row(XL)

XL_Format_HAlign(XL,RG:=Header_RG,h:=2) ;1=Left 2=Center 3=Right
XL_Format_VAlign(XL,RG:=Header_RG,v:=4) ;1=Top 2=Center 3=Distrib 4=Bottom
XL_Format_Font(XL,RG:=Header_RG,Font:="Arial Narrow",Size:=11) ;Arial, Arial Narrow, Calibri
XL.Range("A1:F1").Interior.ColorIndex := 19 ;Shade header row yellow
XL.Range("A2:F2").Interior.ColorIndex := 6 ;Intense Yellow
XL.Range("A1:F2").Font.Bold := 1 ;Bold
XL_Border(XL,RG:=Header_RG,Weight:=2,Line:=2) ;1=Hairline 2=Thin 3=Med 4=Thick  ;Line1=Solid 2=Dash 4=DashDot 5=DashDotDot
XL_Row_Height(XL,RG:="1:" LR "=-1") ;rows first then height -1 is auto
XL_Col_Width_Set(XL,RG:="A=10|B=30|C=30|D=90|E=8|F=175") ;-1 is auto
;**********************replace (chr10) with <br>*********************************
if (Run_Search_Replace =1)
	XL.Range("C2:C" LR).Replace("(chr10)",Chr(10))  ;need to convert to function 
;**********************hyperlink*********************************
XL_Hyperlink_Offset_Col2(XL,RG:="a3:a" LR,URL:="3",Freindly:="0") ;Neg values are rows Above/ Pos are Rows below
return



;**********************verify url in href*********************************
Verify_href:
XL:=XL_Handle(1) ;XL_Handle(XL,1) ;1=Application 2=Workbook 3=Worksheet
LR:=XL_Last_Row(XL)
Verify_Link(XL,RG:="D3:D" LR ,Col_Dest:=2)
return

;*******************************************************
;**********************Content*********************************
;*******************************************************
Content:
pwb:=GetIE()
TAG:="DIV"
;~ msgbox % pwb.document.getElementByID(Body_ID).getElementsByTagName("A")[0].innerTEXT
Div_CT:=pwb.document.getElementByID(Body_ID).All.Tags(TAG).length -1 ;[0].innerTEXT
Grp:=pwb.document.getElementByID(Body_ID).All.Tags(TAG)

Loop, %Div_CT% { ;loop over all Div
   Text.= "`n" . Grp[A_Index].Innertext  ;append with line break
  }


Text:= RegExReplace(text, "(^|\R)\K\s+") ;remove blank lines
Xl.Sheets.Add ; Worksheet.Add ;add a new workbook
xl.activesheet.Name := "Content"
Clipboard:=text
XL.Application.ActiveSheet.Range("A1").PasteSpecial()
return

;**********************Site Catalyst *********************************
Site_Catalyst:
pwb:=GetIE()
text := pwb.document.documentElement.innerHTML
RegExMatch(text,"tiPageName\s?=\s?""(.*?)"";",Page_Name)   ; making it greedy so it gets the last one,not the first one
StringLower,Page_Name,Page_Name1
RegExMatch(text,"tiContentGroup\s?=\s?""(.*?)"";",Content_Group)   ; making it greedy so it gets the last one,not the first one
StringLower,Content_Group,Content_Group1
return

;**********************page content- most freq value count*********************************
Word_Count:
pwb:=GetIE()
text:=pwb.Document.body.innertext
top_words:=DuplicateFinderAndCounter(text,TopCounts)
return
;*******************************************************
;**********************End*********************************
;*******************************************************
end:
EndTime := A_TickCount
Elapsed:=EndTime - StartTime  ;~ timetook:=MStoM(Elapsed)
MsgBox, % "Verification is done and it took " MStoM(Elapsed) ; Returns 945m 46s
return


;**********************Functions*********************************
;**********************Insert hyperlinks in Excel*********************************
XL_Hyperlink_Offset_Col2(PXL,RG="",URL="",Freindly=""){
For Cell in PXL.Application.ActiveSheet.Range(RG){
   if (Cell.offset(0,URL).value !="")
     Cell.Value:="=Hyperlink(""" . Cell.offset(0,URL).value . """,""" . Round((Cell.Offset(0,Freindly).Value)) . """)"
  }}

;**********************verify URL by pinging*********************************
Verify_Link(PXL,RG="",Col_Dest=""){
For Cell in PXL.Application.ActiveSheet.Range(RG){
url:=Cell.value
RegExMatch(url,"^(?P<start>.*?)(?P<end>[?|#].*)?$",URL_)  ;breakout parts after URL
url:=RTrim(url, "/") ; trim /
url:=RTrim(url, "#") ; trim pound

if (url="") or (url="#")
   Continue ;don't verify if missing

IfInString, url, javascript
   Continue  ;don't verify if javascript
type:="GET"
ComObjError(false)
WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WebRequest.Open(Type, URL_Start)

WebRequest.SetRequestHeader("Accept", "text/html;charset=utf-8") 
WebRequest.SetRequestHeader("Referer",URL) ;set refering site to url
Cookie=
(
JSESSIONID=3F777724E42CC7EDE6FA8F37D513E038.node13; tidomain=www.ti.com; gpv_p9_o=rf430 learn nfc tab-en; s_cc=true; AP_COOKIE_EN=computerId-C_EN_286630705&geoStateCode-TX&ipGeoMapDate-1426850455286&expiryDate-1458386461914&lastVisitedDate-1426850461914&geoRegion-Americas&createdDate-1425302610354&geoCountryCode-US&ipAddress-156.117.61.214&; AB_TECHDOC_EN=%7C0%7C; AB_PREFERENCE_EN=Y; PROMO_TRACKER_EN=TM4C1230C3PM_17_en_1_2; 
)
WebRequest.SetRequestHeader("Cookie", Cookie)
IfWinExist, Fiddler
   WebRequest.SetProxy(2,"localhost:8888") ;turn off if Fiddler not running

Try {
WebRequest.Send() ;temporarily removed- kept having issues
WebRequest.WaitForResponse(Wait_For_Server) ;wait upto 5 seconds for response
Text:=WebRequest.StatusText
Status:=WebRequest.Status ;numeric value  ;~ Status_Text:=WebRequest.StatusText ;text
} Catch {
Text:="error"
Status:="not tested"
}
  Cell.offset(0,1).Value:=Text "/" Status 
   if (status ="200")
      Cell.offset(0,1).Interior.ColorIndex := 4 ;green
   else if (status ="need to verify manually")
       Cell.offset(0,1).Interior.ColorIndex := 6 ;yellow
   Else Cell.offset(0,1).Interior.ColorIndex := 3 ;green
}
ComObjError(true)
}

;**********************paste into excel*********************************
XL_Paste2(PXL,Dest_RG="",Paste=""){ ;1=All 2=Values 3=Comments 4=Formats 5=Formulas 6=Validation 7=All Except Borders
                                                ;8=Col Widths 11=Formulas and Number formats 12=Values and Number formats
IfEqual,Paste,1,SetEnv,Paste,-4104 ;xlPasteAll
IfEqual,Paste,2,SetEnv,Paste,-4163 ;xlPasteValues
IfEqual,Paste,3,SetEnv,Paste,-4144 ;xlPasteComments
IfEqual,Paste,4,SetEnv,Paste,-4122 ;xlPasteFormats
IfEqual,Paste,5,SetEnv,Paste,-4123 ;xlPasteFormulas
PXL.Application.ActiveSheet.Range(Dest_RG).PasteSpecial(Paste)
}

;**********************get IE*********************************
GetIE(Name="") { ; GetIE(tab_name)
   If(Name) {
      WinGet, winList, List, ahk_class IEFrame
      While(winList%A_Index% && !m) {
         n := A_Index, ErrorLevel := 0
         While(!ErrorLevel && !m) {
            ControlGetText, tabText, TabWindowClass%A_Index%, % "ahk_id" winList%n%
            If InStr(tabText, Name)
               m := A_Index ; win hwnd = winList%n%
      }   }
      ControlGet, hIESvr, hWnd, , Internet Explorer_Server%m%, % "ahk_id" winList%n%
   } Else ControlGet, hIESvr, hWnd, , Internet Explorer_Server1, ahk_class IEFrame ; get Active IE
   If Not hIESvr
      Return
COM_Init()   
   DllCall("SendMessageTimeout", "Uint", hIESvr, "Uint", DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT"), "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lResult)
   DllCall("oleacc\ObjectFromLresult", "Uint", lResult, "Uint", COM_GUID4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}"), "int", 0, "UintP", pdoc)
   IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
   pweb := COM_QueryService(pdoc,IID_IWebBrowserApp,IID_IWebBrowserApp), COM_Release(pdoc)
   Return pweb
}

;**********************Time to complete*********************************
MStoM(ms) { ; Convert Milliseconds to a string of minutes and seconds
   Orig := A_FormatFloat ; Store previous Float format
   SetFormat, Float, 0.1 ; One decimal place
   m := ms / 1000 / 60 ; minutes
   m := SubStr(m, 1, StrLen(m)-2) ; Remove decimal - No rounding for minutes!
   SetFormat, Float, 0.0 ; No decimals for seconds!
   s := (ms / 1000) - (m * 60) ; subtract minutes from total seconds
   SetFormat, Float, %Orig% ; Restore previous Float format
   Return m . "m " . s . "s" ; Return minutes and seconds as a string
}


;**********************Duplicate and word counter*********************************
DuplicateFinderAndCounter(String, TopCounts) {
    Needle := "[\W]+" ; this is the story, I beleive if you were to change someting it would be this regex, or you can use a simple split or StringReplace/RegExReplace every white space  with line feed

    String:=RegExReplace(String, Needle, "`n") ; replace all non word strings with new lines

;**********************remove short words & words not want to track*********************************
StringLower,string,string
Loop,parse, string, `n 
{
	if StrLen(A_loopfield)=1
		Continue
	if A_loopfield not in as,are,up,or,not,the,that,this,is,in,your,more,from,what,for,of,and,to,use,on,can,by,www,http,with,hi,low,high,new,index,if,id,var
		String2.= A_Loopfield "`n"
}
string:=String2

Sort, String  ; sort the string

    p:=1, needle := "im`n)^(.*)(\n\1)+`n"
    while p:=RegExMatch(String, needle, duplicate, p+strlen(duplicate)){ ; search for consecutive same lines
        StringReplace, s, duplicate, `n,, UseErrorLevel ; get the count of existing lines by using UseErrorLevel
        Duplicates .= ErrorLevel A_Space duplicate1 "`n" ; add the count and the word
    }
    Duplicates:=trim(Duplicates, "`n")
    Sort, Duplicates, RF SortingWithRegEx ; here we sort numerically, each either that, or we do it some other way...
    if f := instr(Duplicates, "`n", false, 1, TopCounts) ; get for the tenth line feed, if there is at least 10
       Duplicates:=substr(Duplicates, 1, f) ; return the top ten, if....
       StringReplace, Duplicates, Duplicates, `n,|,all
       stringtrimright,Duplicates, Duplicates, 1
    return, Duplicates
}
 
SortingWithRegEx(a1, a2) {
    RegExMatch(a1, "(^\d+)", f1)
    RegExMatch(a2, "(^\d+)", f2)
    return f1 > f2 ? -1 : 1
}
;~ Joe Glines   https://the-Automator.com  https://www.the-automator.com/excel-and-autohotkey/
;todo;  xl.Range(xl.Cells(1,1),xl.Cells(1,3)).select  ;you can reference columns by an index. row,col
;***********************Excel Handles********************************.
;~ XL:=XL_Handle(1) ; 1=pointer to Application   2= Pointer to Workbook
XL_Handle(Sel){
	ControlGet, hwnd, hwnd, , Excel71, ahk_class XLMAIN ;identify the hwnd for Excel
	Obj:=ObjectFromWindow(hwnd,-16)
	return (Sel=1?Obj.Application:Sel=2?Obj.Parent:Sel=3?Obj.ActiveSheet:"")
}
;***borrowd & tweaked from Acc.ahk Standard Library*** by Sean  Updated by jethrow*****************
ObjectFromWindow(hWnd, idObject = -4){
	if(h:=DllCall("LoadLibrary","Str","oleacc","Ptr"))
		If DllCall("oleacc\AccessibleObjectFromWindow","Ptr",hWnd,"UInt",idObject&=0xFFFFFFFF,"Ptr",-VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
			Return ComObjEnwrap(9,pacc,1)
}
;***********************Show name of object handle is referencing********************************.
;~ XL_Reference(XL) ;will pop up with a message box showing what pointer is referencing
XL_Reference(PXL){
	;~ MsgBox, %HWND%
	;~ MsgBox, % ComObjType(window)
	MsgBox % ComObjType(PXL,"Name")
}

;;********************Reference Cell by row and column number***********************************
;~ XL.Range(XL.Cells(1,1).Address,XL.Cells(5,5).Address)
;~ MsgBox % XL.Cells(1,4).Value  ;Row, then column
;~ XL.Range(XL.Cells(1,1).Address,XL.Cells(5,5).Address)

;***********************Screen update toggle********************************.
;~ XL_Screen_Update(XL)
XL_Screen_Update(PXL){
	PXL.Application.ScreenUpdating := ! PXL.Application.ScreenUpdating ;toggle update
}

;~ XL_Speedup(XL,1) ;Speed up Excel tweaked from Tre4shunter https://github.com/tre4shunter/XLFunctions/
XL_Speedup(PXL,Status){ ;Helps COM functions work faster/prevent screen flickering, etc.
	if(!Status){
		PXL.application.displayalerts := 0
		PXL.application.EnableEvents := 0
		PXL.application.ScreenUpdating := 0
		PXL.application.Calculation := -4135
	}else{
		PXL.application.displayalerts := 1
		PXL.application.EnableEvents := 1
		PXL.application.ScreenUpdating := 1
		PXL.application.Calculation := -4105
	}
}

;~ XL_Screen_Visibility(XL)
XL_Screen_Visibility(PXL){
	PXL.Visible:= ! PXL.Visible ;Toggle screen visibility
}
;***********************First row********************************.
;~ XL_First_Row(XL)
XL_First_Row(PXL){
	Return, PXL.Application.ActiveSheet.UsedRange.Rows(1).Row
}
;***********************Used Rows********************************.
;~ Rows:=XL_Used_Rows(XL)
XL_Used_rows(PXL){
	;  To do
}
;***********************Last Row********************************.
;~ LR:=XL_Last_Row(XL)
XL_Last_Row(PXL){
	;~  Return PXL.ActiveSheet.Cells.SpecialCells(11).Row ;This will treat formatting as a used cell
	Return PXL.Cells.Find("*",,,,1,2).Row ;Gets last Row but not counting formatting
}

;***********************Last Row in Specific Column********************************.
;~ Last_Row:=XL_Last_Row_in_Column(XL,"A")
XL_Last_Row_in_Column(PXL,Col){
	return PXL.Cells(PXL.Rows.Count,XL_String_To_Number(Col)).End(-4162).Row
}

;~ XL.cells.rows.count count of all rows available in Excel.  Last row available
;***********************First Column********************************.
;~ XL_First_Col_Nmb(XL)
XL_First_Col_Nmb(PXL){
	Return, PXL.Application.ActiveSheet.UsedRange.Columns(1).Column
}
;***********************First Column Alpha**********************************.
;~ XL_Last_Col_Alpha(XL)
XL_First_Col_Alpha(PXL){
	FirstCol:=PXL.Application.ActiveSheet.UsedRange.Columns(1).Column
	return (FirstCol<=26?(Chr(64+FirstCol)):(FirstCol>26)?(Chr((FirstCol-1)/26+64) . Chr(Mod((FirstCol- 1),26)+65)):"")
}
;***********************Used Columns********************************.
;~ LC:=XL_Used_Cols_Nmb(XL)
XL_Used_Cols_Nmb(PXL){
	Return, PXL.Application.ActiveSheet.UsedRange.Columns.Count
}
;***********************Last Column********************************.
;~ LC:=XL_Last_Col_Nmb(XL)
XL_Last_Col_Nmb(PXL){
	;~ Return, PXL.Application.ActiveSheet.UsedRange.Columns(PXL.Application.ActiveSheet.UsedRange.Columns.Count).Column ;This will treat formatted cells as valid data
	return PXL.Cells.Find("*",,,,2,2).Column ;Gets Last Column
}
;***********************Last Column Alpha**  Needs Workbook********************************.
;~ XL_Last_Col_Alpha(XL)
XL_Last_Col_Alpha(PXL){
	d:=XL_Last_Col_Nmb(PXL)
	while(d>0){
		m:=Mod(d-1,26)
		Col:=Chr(65+m) Col
		d:=Floor((d-m)/26)
	}return Col
}
;***********************Used_Range Used range********************************.
;~ RG:=XL_Used_RG(XL,Header:=1) ;Use header to include/skip first row
XL_Used_RG(PXL,Header=1){
	return Header=0?XL_First_Col_Alpha(PXL) . XL_First_Row(PXL) ":" XL_Last_Col_Alpha(PXL) . XL_Last_Row(PXL):Header=1?XL_First_Col_Alpha(PXL) . XL_First_Row(PXL)+1 ":" XL_Last_Col_Alpha(PXL) . XL_Last_Row(PXL):""
}
;***********************Numeric Column to string********************************.
;~ XL_Col_To_Char(26)
XL_Col_To_Char(Index){ ;Converting Columns to Numeric for Excel
	return Index<=26?(Chr(64+index)):Index>26?Chr((index-1)/26+64) . Chr(mod((index - 1),26)+65):""
}
;***********************String to Number********************************.
;~ XL_String_To_Number("ab")
XL_String_To_Number(Column){
	StringUpper, Column, Column
	Index := 0
	Loop, Parse, Column  ;loop for each character
	{ascii := asc(A_LoopField)
    	if (ascii >= 65 && ascii <= 90)
		index := index * 26 + ascii - 65 + 1    ;Base = 26 (26 letters)
	else { return
	} }
return, index+0 ;Adding zero here is needed to ensure you're returning an Integer, not a String
}
;***********************Freeze Panes********************************.
;~ XL_Freeze(XL,Row:="1",Col:="B") ;Col A will not include cols which is default so leave out if unwanted
;***********************Freeze Panes in Excel********************************.
XL_Freeze(PXL,Row="",Col="A"){
	PXL.Application.ActiveWindow.FreezePanes := False ;unfreeze in case already frozen
	IfEqual,row,,return ;if no row value passed row;  turn off freeze panes
	PXL.Application.ActiveSheet.Range(Col . Row+1).Select ;Helps it work more intuitivly so 1 includes 1 not start at zero
	PXL.Application.ActiveWindow.FreezePanes := True
}

;*******************************************************.
;***********************Formatting********************************.
;*******************************************************.
;***********************Alignment********************************.
;~ XL_Format_HAlign(XL,RG:="A1:A10",h:=2) ;1=Left 2=Center 3=Right
XL_Format_HAlign(PXL,RG="",h="1"){ ;defaults are Right bottom
	PXL.Application.ActiveSheet.Range(RG).HorizontalAlignment:=(h=1?-4131:h=2?-4108:h=3?-4152?h=4:-4108:"")
	/*
		IfEqual,h,1,Return,PXL.Application.ActiveSheet.Range(RG).HorizontalAlignment:=-4131 ;Left
		IfEqual,h,2,Return,PXL.Application.ActiveSheet.Range(RG).HorizontalAlignment:=-4108 ;Center
		IfEqual,h,3,Return,PXL.Application.ActiveSheet.Range(RG).HorizontalAlignment:=-4152 ;Right
	*/
}
;~ XL_Format_VAlign(XL,RG:="A1:A10",v:=4) ;1=Top 2=Center 3=Distrib 4=Bottom 5=Horiz align
XL_Format_VAlign(PXL,RG="",v="1"){
	PXL.Application.ActiveSheet.Range(RG).VerticalAlignment:=(v=1?-4160:v=2?-4108:v=3?-4117:v=4?-4107:"")
	/*
		IfEqual,v,1,Return,PXL.Application.ActiveSheet.Range(RG).VerticalAlignment:=-4160 ;Top
		IfEqual,v,2,Return,PXL.Application.ActiveSheet.Range(RG).VerticalAlignment:=-4108 ;Center
		IfEqual,v,3,Return,PXL.Application.ActiveSheet.Range(RG).VerticalAlignment:=-4117 ;Distributed
		IfEqual,v,4,Return,PXL.Application.ActiveSheet.Range(RG).VerticalAlignment:=-4107 ;Bottom
		IfEqual,v,4,Return,PXL.Application.ActiveSheet.Range(RG).VerticalAlignment:=-4107 ;Bottom
		*/
}
;***********************Wrap text********************************.
;~ XL_Format_Wrap(XL,RG:="A1:B4",Wrap:=0) ;1=Wrap text, 0=no
XL_Format_Wrap(PXL,RG:="",Wrap:="1"){ ;defaults to Wrapping
	PXL.Application.ActiveSheet.Range(RG).WrapText:=Wrap
}

;********************Indent text in a cell***********************************
;~ XL_Indent(XL,"A1:A10",3)
XL_Indent(PXL,RG,Indent){
	PXL.Application.ActiveSheet.Range(RG).IndentLevel := 3
}
;***********Shrink to fit*******************
;~ XL_Format_Shrink_to_Fit(XL,RG:="A1",Shrink:=0) ;1=Wrap text, 0=no
XL_Format_Shrink_to_Fit(PXL,RG:="",Shrink:="1"){ ;defaults to Shrink to fit
	(Shrink=1)?(PXL.Application.ActiveSheet.Range(RG).WrapText:=0) ;if setting Shrink to fit need to turn-off Wrapping
	PXL.Application.ActiveSheet.Range(RG).ShrinkToFit :=Shrink
}

;***********************Merge / Unmerge cells********************************.
;~ XL_Merge_Cells(XL,RG:="A12:B13",Warn:=0,Merge:=1) ;set to true if you want them merged
XL_Merge_Cells(PXL,RG,warn:=0,Merge:=0){ ;default is unmerge and warn off
	PXL.Application.DisplayAlerts := warn ;Warn about unmerge keeping only one cell
	PXL.Application.ActiveSheet.Range(RG).MergeCells:=Merge ;set merge for range
	(warn=0)?(PXL.Application.DisplayAlerts:=1) ;if warnings were turned off, turn back on
}
;***********************Font size, type, ********************************.
;~ XL_Format_Font(XL,RG:="A1:B1",Font:="Arial Narrow",Size:=25) ;Arial, Arial Narrow, Calibri,Book Antiqua
XL_Format_Font(PXL,RG:="",Font:="Arial",Size:="11"){
	PXL.Application.ActiveSheet.Range(RG).Font.Name:=Font
	PXL.Application.ActiveSheet.Range(RG).Font.Size:=Size
}

;********************Font color***********************************
;2=none 3=Red 4=Lt Grn 5=Blue 6=Brt Yel 7=Mag 8=brt blu 15=Grey 17=Lt purp  19=Lt Yell 20=Lt blu 22=Salm 26=Brt Pnk
;~ XL_Format_Font_Color_RGB(XL,RG:="A1",3)
XL_Format_Font_Color(PXL,RG:="",Color:=0){
	PXL.Application.ActiveSheet.Range(RG).Font.ColorIndex:=Color
}

;********************Font color***********************************
;~ XL_Format_Font_Color_RGB(XL,RG:="A1",Red:=0,Green:=0,Blue:=0,Color:="Red")
XL_Format_Font_Color_RGB(PXL,RG:="",Red:=0,Green:=0,Blue:=0,Color:=""){
	If (Color){
		(Color="White")?(Red:=255,Green:=255,Blue:=255)
         :(Color="Red")  ?(Red:=255,Green:=0  ,Blue:=0)
         :(Color="Green")?(Red:=0  ,Green:=255,Blue:=0)
         :(Color="Blue") ?(Red:=0  ,Green:=0  ,Blue:=255)
         :                (Red:=0  ,Green:=0  ,Blue:=0) ;otherwise make it black
	}
	PXL.Application.ActiveSheet.Range(RG).Font.Color:=(Blue<<16) + (Green<<8) + Red ;eduardo bispo

}


;***********************Font bold, normal, italic, Underline********************************.
;~ XL_Format_Format(XL,RG:="A1:B1",1) ; Bold:=1,Italic:=0,Underline:=3  Underline 1 thru 5
XL_Format_Format(PXL,RG:="",Bold:=0,Italic:=0,Underline:=0){
	PXL.Application.ActiveSheet.Range(RG).Font.Bold:= bold
	PXL.Application.ActiveSheet.Range(RG).Font.Italic:=Italic
	(Underline="0")?(PXL.Application.ActiveSheet.Range(RG).Font.Underline:=-4142):(PXL.Application.ActiveSheet.Range(RG).Font.Underline:=Underline+1)
}
;***********Cell Shading*******************
;2=none 3=Red 4=Lt Grn 5=Blue 6=Brt Yel 7=Mag 8=brt blu 15=Grey 17=Lt purp  19=Lt Yell 20=Lt blu 22=Salm 26=Brt Pnk
;~ XL_Format_Cell_Shading(XL,RG:="A1:H1",Color:=28)
XL_Format_Cell_Shading(PXL,RG:="",Color:=0){
	PXL.Application.ActiveSheet.Range(RG).Interior.ColorIndex :=Color
}
;***********************Cell Number format********************************.
;~ XL_Format_Number(XL,RG:="A1:B4",Format:="#,##0") ;#,##0 ;0,000 ;0,00.0 ;0000 ;000.0 ;.0% ;$0 ;m/dd/yy ;m/dd ;dd/mm/yyyy ;for plain text use:="@"
XL_Format_Number(PXL,RG:="",format="#,##0"){
	PXL.Application.ActiveSheet.Range(RG).NumberFormat := Format
}
;***********tab/Worksheet color*******************
;1=Black 2=White  3=Red 4=Lt Grn 5=Blue 6=Brt Yel 7=Mag 8=brt blu 15=Grey 17=Lt purp  19=Lt Yell 20=Lt blu 22=Salm 26=Brt Pnk
;XL_Tab_Color(xl,"Sheet1","4")
XL_Tab_Color(PXL,Sheet_Name,Color){
	PXL.Sheets(Sheet_Name).Tab.ColorIndex:=Color ;color tab yellow
}
;********************Select / Activate sheet***********************************
;XL_Select_Sheet(XL,"Sheet2")
XL_Select_Sheet(PXL,Sheet_Name){
	PXL.Sheets(Sheet_Name).Select
}

;XL_Format_Text_Alignment(XL,"A1","80")
;********************Change text orientation***********************************
XL_Format_Text_Alignment(PXL,RG:="",Rotate:="90"){
	PXL.Range(RG).Orientation:=Rotate
}

;***********************Search- find text- Cell shading and Font color********************************.
;~ XL_Color(PXL:=XL,RG:="A1:D50",Value:="Joe",Color:="2",Font:=1) ;change the font color
;~ XL_Color(PXL:=XL,RG:="A1:D50",Value:="Joe",Color:="1") ;change the interior shading
;***********************to do ********************************.
;*this is one or the other-  redo it so it does both***************.
;~ XL_Color(XL,"A1:A2","asdf",<Color Value>,<Background=0,Text=1>)
XL_Color(PXL:="",RG:="",Value="",CellShading:="1",FontColor:="0"){
	if(f:=PXL.Application.ActiveSheet.Range[RG].Find[Value]){
		first :=f.Address
		Loop
		{
			f.Interior.ColorIndex:=CellShading
			f.Font.ColorIndex :=FontColor
			f :=PXL.Application.ActiveSheet.Range[RG].FindNext[f]
			if(Last)
				Break
			if(PXL.Application.ActiveSheet.Range[RG].FindNext[f].Address=First)
				Last:=1
		}
	}

	return

	/*
		if  f:=PXL.Application.ActiveSheet.Range[RG].Find[Value]{ ; if the text can be found in the Range
			first :=f.Address  ; save the address of the first found match
			Loop
				If (FontColor=0){
					f.Interior.ColorIndex:=CellShading
					f :=PXL.Application.ActiveSheet.Range[RG].FindNext[f] ;color Interior & move to next found cell
				}Else{
				f.Font.ColorIndex :=FontColor, f :=PXL.Application.ActiveSheet.Range[RG].FindNext[f] ;color font & move to next found cell
			}Until (f.Address = first) ; stop looking when we're back to the first found cell
		}
	*/
}

;***********************Cell Borders (box)********************************.
;***********Note- some weights and linestyles overwrite each other*******************
;~ XL_Border(XL,RG:="a20:b21",Weight:=2,Line:=2) ;Weight 1=Hairline 2=Thin 3=Med 4=Thick  ***  Line 0=None 1=Solid 2=Dash 4=DashDot 5=DashDotDot 13=Slanted Dashes
;***********************Cell Borders (box)********************************.
XL_Border(PXL,RG:="",Weight:="3",Line:="1"){
	Line:=Line=0?-4142:Line
	/*
		xlContinuous		1	Continuous line.
		xlDash			-4115	Dashed line.
		xlDashDot			4	Alternating dashes and dots.
		xlDashDotDot		5	Dash followed by two dots.
		xlDot			-4118	Dotted line.
		xlDouble			-4119	Double line.
		xlLineStyleNone	-4142	No line.
		xlSlantDashDot		13	Slanted dashes.
	*/
	/*
		https://docs.microsoft.com/en-us/office/vba/api/excel.xlbordersindex
		PXL.Application.ActiveSheet.Range(RG).Borders(6).Weight:=1
		xlDiagonalDown		5	Border running from the upper-left corner to the lower-right of each cell in the range.
		xlDiagonalUp		6	Border running from the lower-left corner to the upper-right of each cell in the range.
		xlEdgeLeft		7	Border at the left edge of the range.
		xlEdgeTop			8	Border at the top of the range.
		xlEdgeBottom		9	Border at the bottom of the range.
		xlEdgeRight		10	Border at the right edge of the range.
		xlInsideVertical	11	Vertical borders for all the cells in the range except borders on the outside of the range.
		xlInsideHorizontal	12	Horizontal borders for all cells in the range except borders on the outside of the range.
	*/
	Obj:=PXL.Application.ActiveSheet.Range(RG)
	while((Index:=A_Index+6)<=10){
		Border:=Obj.Borders(Index)
		Border.Weight:=Weight
		Border.LineStyle:=Line
	}
}

;***********************Row Height********************************.
;~ XL_Row_Height(XL,RG:="1:4=-1|10:13=50|21=15") ;rows first then height -1 is auto
XL_Row_Height(PXL,RG:=""){
	for k, v in StrSplit(rg,"|") ;Iterate over array
		((Obj:=StrSplit(v,"=")).2="-1")?(PXL.Application.ActiveSheet.rows(Obj.1).AutoFit):(PXL.Application.ActiveSheet.rows(Obj.1).RowHeight:=Obj.2)
}

;***********************Column Widths********************************.
;~ XL_Col_Width_Set(XL,RG:="A:B=-1|D:F=-1|H=15|K=3") ;-1 is auto
XL_Col_Width_Set(PXL,RG:=""){
	for k, v in StrSplit(rg,"|") ;Iterate over array
		((Obj:=StrSplit(v,"=")).2="-1")?(PXL.Application.ActiveSheet.Columns(Obj.1).AutoFit):(PXL.Application.ActiveSheet.Columns(Obj.1).ColumnWidth:=Obj.2)
}

;***********************Column Insert********************************.
XL_Col_Insert(PXL,RG:="",WD:="5"){ ;Default width is 5
	PXL.Application.ActiveSheet.Columns(RG).Insert(-4161)
	PXL.Application.ActiveSheet.Columns(RG).ColumnWidth:=WD
}

;***********************Row Insert********************************.
;~ XL_Row_Insert(XL,RG:="1:5",HT:=16)  ;~ XL_Row_Insert(XL,RG:="1")
XL_Row_Insert(PXL,RG:="",HT:="15"){ ;default height is 15
	PXL.Application.ActiveSheet.Rows(RG).Insert(-4161)
	PXL.Application.ActiveSheet.Rows(RG).RowHeight:=HT
}

;***********************Column Delete********************************.
;~  XL_Col_Delete(XL,RG:="A:B|F|G|Z|BD ")
XL_Col_Delete(PXL,RG:=""){
	for j,k in StrSplit(RG,"|")
		List.=(InStr(k,":")?k:k ":" k) "," ;need to make for two if only 1 Row
	PXL.Application.ActiveSheet.Range(Trim(List,",")).Delete
}

;***********************Row Delete********************************.
;~ XL_Row_Delete(XL,RG:="4:5|9|67|9|10") ;range or single but cannot overlap
XL_Row_Delete(PXL,RG:=""){
	for j,k in StrSplit(RG,"|")
		List.=(InStr(k,":")?k:k ":" k) "," ;need to make for two if only 1 Row
	PXL.Application.ActiveSheet.Range(Trim(List,",")).Delete ;use list but remove final comma
}

;***********************Delete Column Based on Value********************************.
;~ XL_Delete_Col_Based_on_Value(XL,RG:="A1:H1",Val:="Joe")
XL_Delete_Col_Based_on_Value(PXL,RG:="",Val:=""){
	Columns:=[]
	For C in PXL.Application.ActiveSheet.Range(RG)
		If(C.Value==Val)
			Columns.InsertAt(1,(Col:=XL_Col_To_Char(C.Column)) ":" Col)
	for a,b in Columns
		PXL.Application.ActiveSheet.Range(b).EntireColumn.Delete
}

;***********************Row delete based on Column value********************************.
;~ XL_Delete_Row_Based_on_Value(XL,RG:="B1:B20",Val:="Joe")
XL_Delete_Row_Based_on_Value(PXL,RG:="",Val:=""){
	Rows:=[]
	For C in PXL.Application.ActiveSheet.Range(RG)
		If(C.Value==Val)
			Rows.InsertAt(1,(C.Row) ":" C.Row)
	for a,b in Rows
		PXL.Application.ActiveSheet.Range(b).EntireRow.Delete
}

;***********looping over cells*******************
/*
	For Cell in xl.range(XL.Selection.Address) {
		Current_Cell:=Cell.Address(0,0) ;get absolue reference; change to 1 if want releative
		MsgBox % cell.value
	}
*/


;*******************************************************.
;***********************Clipboard actions********************************.
;*******************************************************.
;***********************Copy to clipboard********************************.
;~ XL_Copy_to_Clipboard(XL,RG:="A1:A5")
XL_Copy_to_Clipboard(PXL,RG:=""){
	PXL.Application.ActiveSheet.Range(RG).Copy ;copy to clipboard
}

;***********************Copy to a var and specify delimiter********************************.
;~ XL_Copy_to_Var(XL,RG:="A1:A5",Delim="|")
XL_Copy_to_Var(PXL,RG:="",Delim:="|"){ ;pipe is defualt
	For Cell in PXL.Application.ActiveSheet.Range(RG)
		Data.=Cell.Text Delim
	return Data:=Trim(Data,Delim) ;trimming off last delimiter
}
XL_Copy_To_Object(PXL,RG:="",Blank_Values:=0){
	Data:=[]
	For Cell in PXL.Application.ActiveSheet.Range(RG)
		if(Cell.Text||Blank)
			Data[Cell.Address(0,0)]:=Cell.Text
	return Data
}
;***********************Paste ********************************.
;~ XL_Paste(XL,Source_RG:="C1",Dest_RG:="F1:F10",Paste:=1)
XL_Paste(PXL,Source_RG:="",Dest_RG:="",Paste:=""){       ;1=All 2=Values 3=Comments 4=Formats 5=Formulas 6=Validation 7=All Except Borders
	IfEqual,Paste,1,SetEnv,Paste,-4104 ;xlPasteAll        ;8=Col Widths 11=Formulas and Number formats 12=Values and Number formats
	IfEqual,Paste,2,SetEnv,Paste,-4163 ;xlPasteValues
	IfEqual,Paste,3,SetEnv,Paste,-4144 ;xlPasteComments
	IfEqual,Paste,4,SetEnv,Paste,-4122 ;xlPasteFormats
	IfEqual,Paste,5,SetEnv,Paste,-4123 ;xlPasteFormulas
	; Everything after 5 is the correct parameter for the setting  I.e. "All Except Borders"=7
	PXL.Application.ActiveSheet.Range(Source_RG).Copy
	PXL.Application.ActiveSheet.Range(Dest_RG).PasteSpecial(Paste)
}

;********************Select Cells / Range***********************************
;~ XL_Select_Range(XL,"A1:A4")
XL_Select_Range(PXL,Range,Sheet_Name:=""){
	if (Sheet_Name="")
		PXL.Application.ActiveSheet.Range(Range).Select
	Else {
		XL_Select_Sheet(PXL,Sheet_Name)
		PXL.Sheets(Sheet_Name).Range(Range).Select
	}
}


;***********************deselect cells ********************************.
;~ XL_UnSelect(XL) ;Unselects highlighted cells
XL_UnSelect(PXL){
	PXL.Application.ActiveSheet.CutCopyMode := False
}
;***********************Set cell values / Formulas********************************.
;~ XL_Set_Values(XL,{"A1":"the","A2":"last","B1":"term"}) ;Destination cell & Words are in an object with key-value pairs
XL_Set_Values(PXL,Obj){
	For key,Value in Obj ;use For loop to iterate over object keys & Values
		PXL.Application.ActiveSheet.Range(key).Value:=Value ;Set the cell(key) to the corresponding value
}
;***********************Insert Comment********************************.
;~ XL_Insert_Comment(XL,RG:="b3",Comment:="Hello there`n`rMr monk`n`rWhatup",Vis:=1,Size:=11,Font:="Book Antique",ForeClr:=5)
XL_Insert_Comment(PXL,RG:="",Comment="",Vis:=0,Size:=11,Font:="Arial",ForeClr:=5){
	If (PXL.Application.ActiveSheet.Range(RG).comment.text) <> ""
		PXL.Application.ActiveSheet.Range(RG).Comment.Delete
	PXL.Application.ActiveSheet.Range(RG).Addcomment(Comment)
	PXL.Application.ActiveSheet.Range(RG).Comment.Visible := Vis
	PXL.Application.ActiveSheet.Range(RG).Comment.Shape.Fill.ForeColor.SchemeColor:=ForeClr
	PXL.Application.ActiveSheet.Range(RG).Comment.Shape.TextFrame.Characters.Font.size:=Size
	PXL.Application.ActiveSheet.Range(RG).Comment.Shape.TextFrame.Characters.Font.Name:=Font
}
;***********Insert new worksheet*******************
;~  XL_Insert_Worksheet(XL,"Test")
XL_Insert_Worksheet(PXL,Name:=""){
	PXL.Sheets.Add ; Worksheet.Add ;add a new workbook
	If (Name)
		PXL.ActiveSheet.Name := Name
}
XL_Delete_Worksheet(PXL,Name=""){
	/*
		(Name)?PXL.Sheets(Name).Delete():PXL.ActiveSheet.Delete()
	*/
	If !(Name)
		PXL.ActiveSheet.Delete()
	Else PXL.Sheets(Name).Delete()
}
;********************Rename sheet***********************************
;~ XL_Rename_Sheet(XL,"Sheet 1","New_Name")
XL_Rename_Sheet(PXL,Orig_Name,New_Name){
	PXL.Sheets(Orig_Name).Name := New_Name
}
;********************move Active worksheet to be first***********************************
XL_Move_Active_Sheet_to_First(PXL){
	PXL.ActiveSheet.Move(PXL.Sheets(1)) ;# move active sheet to front
}
;********************Move X sheet to y location***********************************
XL_Move_Xindex_to_yIndex(PXL,Orig_Index,Dest_Index){
	PXL.Sheets(Orig_Index).Move(PXL.Sheets(Dest_Index))
}
;********************Move XXX sheet name to y location***********************************
XL_Move_SheetName_to_yIndex(PXL,Sheet_Name,Dest_Index){
	PXL.Sheets(Sheet_Name).Move(PXL.Sheets(Dest_Index))
}
;***********************Insert Hyperlink********************************.
;url needs to be in format https://www.google.com
;~ XL_Insert_Hyperlink(XL,URL:="B1",Display:="C1",Destination_Cell:="B8")
;~ XL_Insert_Hyperlink(XL,URL:="""https://the-Automator.com""",Display:="""Coo coo""",Destination_Cell:="C2")
XL_Insert_Hyperlink(PXL,URL,Display,Destination_Cell){
	PXL.Application.ActiveSheet.Range(Destination_Cell).Value:="=Hyperlink(" URL "," Display ")"
}

;***********************Insert Hyperlink via OFFSET in Columns (data is in rows)******************.
;~ XL_Insert_Hyperlink_Offset_Col(XL,RG:="E1:E8",URL:="-3",Freindly:="-2") ;Neg values are col to left / Pos are col to right
XL_Insert_Hyperlink_Offset_Col(PXL,Destination_RG,URL_Offset,Freindly_Offset){
	For Cell in PXL.Application.ActiveSheet.Range(Destination_RG){
		Cell.Value:="=Hyperlink(""" . Cell.offset(0,URL_Offset).value . """,""" . Cell.Offset(0,Freindly_Offset).Text . """)"
}}
;***********************Insert Hyperlink via OFFSET in Rows (data is in Columns)******************.
;~ XL_Insert_Hyperlink_Offset_Row(XL,RG:="B18:C18",URL:="-2",Freindly:="-1") ;Neg values are rows Above/ Pos are Rows below
XL_Insert_Hyperlink_Offset_Row(PXL,RG:="",URL_Offset:="",Freindly_Offset:=""){
	For Cell in PXL.Application.ActiveSheet.Range(RG){
		Cell.Value:="=Hyperlink(" "" . Cell.offset(URL_Offset,0).value . """,""" . Cell.Offset(Freindly_Offset,0).Value . """)"
}}
;***********************Remove Hyperlink********************************.
;~ XL_Delete_Hyperlink_on_URL(XLs,RG="B1:B10")
XL_Delete_Hyperlink_on_URL(PXL,RG){
	For Cell in PXL.Application.ActiveSheet.Range(RG)
		Cell.Hyperlinks.Delete
}
;********************Get hyperlinks from selection and push into offset***********************************
;~ XL_GetHyperlinks(XL,0,1) ;first # is row, second is col.  1 is down or right
XL_GetHyperlinks(PXL,Row_Offset=0,Col_Offset=1,RG=""){
	RG:=RG?RG:PXL.Selection.Address(0,0) ;If RG is blank, Get selection for use
	;~ msgbox % RG
	For Cell in PXL.Application.ActiveSheet.Range(RG){ ;loop over selection
		try if(cell.Hyperlinks(1).Address){ ;only do if there is a hyperlinks
			;~ msgbox % cell.text
			If (Row_Offset=0) and (Col_Offset=0) ;if there is no offset, then return the data
				Text.=cell.Value A_Tab cell.Hyperlinks(1).Address "`n" ;append to var with tab delimiting
			Else
				cell.Offset(Row_Offset,Col_Offset).Value:=cell.Hyperlinks(1).Address
	}} Return text
}

;***********************insert email link********************************.
;~ XL_Insert_Email(XL,"A2","C2","E2","B2","D2")
XL_Insert_Email(PXL,email,Subj,Body,Display,Destination_RG:=""){
	PXL.Application.ActiveSheet.Range(Destination_RG).Value:= "=HYPERLINK(""Mailto:"
   . PXL.Application.ActiveSheet.Range(email).value
   . "?Subject=" . PXL.Application.ActiveSheet.Range(Subj).value
   . "&Body=" . PXL.Application.ActiveSheet.Range(Body).value ""","""
   . PXL.Application.ActiveSheet.Range(Display).Value . """)"
}
;***********************Insert email OFFSET in Columns ********************************.
;~ XL_Insert_email_Offset_Col(XL,RG:="E1:E5",URL:="-4",Freindly:="-3",Subj:="-2",Body:="-1") ;Neg values are col to left / Pos are col to right
XL_Insert_email_Offset_Col(PXL,Destination_RG,email_OffSet:="",Freindly_OffSet:="",Subj_OffSet:="",Body_OffSet:=""){
	For Cell in PXL.Application.ActiveSheet.Range(Destination_RG){
		Cell.Value:="=Hyperlink(""mailto:" . Cell.offset(0,email_OffSet).value
		. "?Subject=" . Cell.offset(0,Subj_OffSet).Value "&Body=" Cell.offset(0,Body_OffSet).Value ""","""
		. Cell.Offset(0,Freindly_OffSet).Value  """)"
}}
;***********************Insert email OFFSET in Rows ********************************.
;~ XL_email_Offset_Row(XL,RG:="B24:D24",URL:="-3",Freindly:="-2",Subj:="-1") ;Neg values are Rows Above / Pos are Rows below
XL_email_Offset_Row(PXL,Destination_RG,URL:="",Freindly:="",Subj:=""){
	For Cell in PXL.Application.ActiveSheet.Range(Destination_RG){
		Cell.Value:="=Hyperlink(""mailto:" . Cell.offset(URL,0).value . "?Subject=" . Cell.offset(Subj,0).Value . """,""" . Cell.Offset(Freindly,0).Value . """)"
}}

;~ XL_Search_Replace(XL,RG:="A1:A39",Sch:="Text",Rep:="New Text",Match_Case:="True",CellCont:=0) ;CC=1 Exact, 2=Any
XL_Search_Replace(PXL,RG:="",Sch:="",Rep:="",Match_Case:="0",Exact_Match:="0"){
	Exact_Match:= (Exact_Match="0")?("2"):("1") ;If set to zero then change to 2 so matches any
	;~ Exact_Match:= Exact_Match=0?2:1 ;If set to zero then change to 2 so matches any
	RG:=(RG)?(RG):(XL_Used_RG(PXL,0)) ;If Range not provided, default to used range
	For Cell in PXL.Application.ActiveSheet.Range(RG){
		If Cell.Find[Sch]{
			cell.Replace(Schedule:=Sch,Replace:=Rep,Exact_Match,SearchOrder:=1,MatchCase:=Match_Case,MatchByte:=True, ComObjParameter(0xB, -1) , ComObjParameter(0xB, -1))
		}
	}
}

;********************VLookup***********************************
;~ XL_VLookup(XL,"E2:E4","D2:D4","A1:B10",2,0)
XL_VLookup(PXL,Destination_RG,Vals_to_Lookup_RG,Source_Array_RG,ColNumb_From_Array,Exact_Match=0){
	PXL.Range(Destination_RG) :=PXL.VLookup(PXL.Range(Vals_to_Lookup_RG).value,PXL.Range(Source_Array_RG),2,0)
}

;**********************Dictionary Search / REplace - multiple in range*********************************
;~ Search_Replace_Multiple(XL,rg:="A1:A10", {"ACC":"Account Spec.","RMK":"Rel Mark"})
XL_Search_Replace_Multiple(PXL,RG:="",Terms:=""){
	RG:=(RG)?(RG):(XL_Used_RG(PXL,0)) ;If Range not provided, default to used range
	For Cell in PXL.Application.ActiveSheet.Range(RG) ;Use For loop to iterate over each cell in range
		for key, val in Terms ;Terms is Object passed in form of dictionary
			if Cell.Value=(key)  ;look for key
				Cell.Value:=Val   ;if found, change to corresponding value
}

;**********************replace "#NULL!"*********************************
;~  XL_Replace_Null(PXL,RG)
XL_Replace_Null(PXL,RG:=""){
	RG:=(RG)?(RG):(XL_Used_RG(PXL,0)) ;If Range not provided, default to used range
	PXL.Range(RG).Replace("#NULL!","")  ;
}

;********************Find location of text and return the position***********************************
;~ XL_Find_And_Return_Position(XL,"A5:F5","5",0,3)
XL_Find_And_Return_Position(PXL,RG:="",Search:="",Absolute:=0,Instance:=1){
	RG:=(RG)?(RG):(XL_Used_RG(PXL,0)) ;If Range not provided, default to used range
	Index:=0
	For Cell in PXL.Application.ActiveSheet.Range(RG) { ;Use For loop to iterate over each cell in range
		if Cell.Value=(Search) { ;Stop looping if you find the value
			Index++ ;Increment Index
			If (Index=Instance){ ;If this is the correct instance
				if Absolute
					Return Cell.address ;;~  Cell with $ in them
				Else Return Cell.address(0,0) ;;Cell without $ in them

				/*
					Return Absolute?Cell.Address:Cell.Address(0,0)
				*/
		}}
	} Return "Not found" ;If finish looping then it was not found
}


;********************search***Find columns based on header********************************.
;~  loc:=XL_Find_Headers_in_Cols(XL,["email","country","Age"]) ;pass search terms as an array
;~  MsgBox % "email: "  loc["email"]   .  "`nCountry: " loc["country's"]   .  "`nAge: " loc["Age"]
XL_Find_Headers_in_Cols(PXL,Values){
	Headers:={} ;need to create the object for storing Key-value pairs of search term and Location
	for k, Search_Term in Values{
		Loop, % XL_Last_Col_Nmb(PXL){ ;loop over all used columns
			if (PXL.Application.ActiveSheet.cells(1,A_Index).Value=Search_Term) ;if cell in row 1, column A_Index = search term
				Headers[Search_Term]:=XL_Col_To_Char(A_Index)  ;"1" ;set column to value in Hearders object
	}} return Headers ;return the key-value pairs Object
}

;***********************Clear********************************.
;~  XL_Clear(XL,RG:="A1:A8",All:=0,Format:=0,Content:=0,Hyperlink:=1,Notes:=0,Outline:=0,Comments:=1) ;0 clears contents but leaves formatting 1 clears both
XL_Clear(PXL,RG:="",All:=0,Format:=0,Content:=0,Hyperlink:=0,Notes:=0,Outline:=0,Comments:=0){
	; https://analysistabs.com/excel-vba/clear-cells-data-range-worksheet/  ;https://msdn.microsoft.com/en-us/vba/excel-vba/articles/range-clearcontents-method-excel
	Obj:=PXL.Application.ActiveSheet.Range(RG)
	if(All=1)
		Obj.Clear           ;clear the range of cells including Formats
	else{
		(Format=1)?(Obj.ClearFormats)    ;clear Formats but leave data
		(Content=1)?(Obj.ClearContents)   ;clear Data but leave Formats
		(Hyperlink=1)?(Obj.ClearHyperlinks) ;clear Hyperlinks but leave formatting & Data
		(Notes=1)?(Obj.ClearNotes)      ;clear Notes
		(Outline=1)?(Obj.ClearOutline)    ;clear Outline
		(Comments=1)?(Obj.ClearComments)   ;clear Comments
	}
}
;***********************Delete blank columns*********** ;Jetrhow wrote this http://www.autohotkey.com/board/topic/69033-basic-ahk-l-com-tutorial-for-excel/?p=557697
;~ XL_Delete_Blank_Col(XL)
XL_Delete_Blank_Col(PXL){
	for column in PXL.Application.ActiveSheet.UsedRange.Columns
		if Not PXL.Application.WorkSheetFunction.count(column)
			delete_range .= column.entireColumn.address(0,0) ","
	Try PXL.Application.Range(Trim(delete_range,",")).delete() ;remove last comma and delete columns
	Catch
		MsgBox,,No Missing Columns, no missing COLUMNS, 1
}
;***********************Delete blank Rows********************************.
;~ XL_Delete_Blank_Row(XL)
XL_Delete_Blank_Row(PXL){
	for Row in PXL.Application.ActiveSheet.UsedRange.Rows
		if Not PXL.Application.WorkSheetFunction.counta(Row)
			delete_range .= Row.entireRow.address(0,0) ","
	Try PXL.Application.Range(Trim(delete_range,",")).delete()
	Catch
		MsgBox,,No Missing Rows, no missing ROWS, 1
}
;***********************Delete Column based on Header********************************.
;~ XL_DropColumns_Per_Header(XL,Values:="One|Two|more")
XL_DropColumns_Per_Header(PXL,Values:=""){
	LoopCount:=XL_Last_Col_Nmb(PXL)
	Loop, %LoopCount% {
		Col:=loopCount-(A_Index-1)
		Header:=PXL.Application.ActiveSheet.cells(1,Col).Value
		Loop, parse, Values, |
			If (Header=A_LoopField)
				PXL.Application.ActiveSheet.Columns(Col).Delete
}}

;~XL_DropRows_Per_First_Col(XL,"Joe")
XL_DropRows_Per_First_Col(PXL,Values:=""){
	Values:=StrSplit(Values,"|")
	LoopCount:=PXL.ActiveSheet.Cells.SpecialCells(11).Row
	Loop, %LoopCount% {
		Row:=LoopCount-(A_Index-1)
		Header:=PXL.Application.ActiveSheet.Cells(Row,1).Text
		for a,Value in Values{
			If (Header==Value){
				PXL.Application.ActiveSheet.Rows(Row).Delete
			}
		}
}}
;***********************Remove Duplicates / Dedupe********************************.
;~ XL_Remove_Dup_Used_Range(XL)
XL_Remove_Dup_Used_Range(PXL,Header_Text:=""){
	Dedupe_CL:=PXL.Application.ActiveSheet.Rows(XL_First_Row(PXL)).Find(Header_Text).column
	PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL)).RemoveDuplicates(Columns:=Dedupe_CL).Header:=1 ;added header
}
;***********************Sort by Column ********************************.
;~ XL_Sort_UsedRange(XL,Head:=1,Sort_Col:="A",Ord:="d") ;Sort used range w/without header
XL_Sort_UsedRange(PXL,Head:="1",Sort_Col:="",Ord:="A"){
	Range:=XL_Used_RG(PXL,Header:=Head)
	StringUpper,Ord,Ord
	Sort_Col:=XL_String_To_Number(Sort_Col)+0 ; w/o the +0 will not work even though it is integer???
	IfEqual,Ord,A,Return,PXL.Application.ActiveSheet.Range(Range).Sort(PXL.Application.ActiveSheet.Columns(Sort_Col),1) ;Ascending
	IfEqual,Ord,D,Return,PXL.Application.ActiveSheet.Range(Range).Sort(PXL.Application.ActiveSheet.Columns(Sort_Col),2) ;Descending
}
;***********************Sort Two Columns********************************.
;~ XL_Sort_TwoCols_UsedRange(XL,1,Sort_1:="a",Ord_1:="D",Sort_2:="b",Ord_2:="d")
XL_Sort_TwoCols_UsedRange(PXL,Head:="1",Sort_1:="b",Ord_1:="a",Sort_2:="c",Ord_2:="a"){
		/*
			StringUpper, Ord_1, Ord_1, StringUpper, Ord_2, Ord_2
			IfEqual, Ord_1,A,SetEnv,Ord_1,1
			IfEqual, Ord_1,D,SetEnv,Ord_1,2
			IfEqual, Ord_2,A,SetEnv,Ord_2,1
			IfEqual, Ord_2,D,SetEnv,Ord_2,2
		*/

		Ord_1:=Ord_1="A"?1:2
		Ord_2:=Ord_2="A"?1:2

	;~ PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=1)).Sort(PXL.Application.ActiveSheet.Columns(XL_String_To_Number(Sort_2)+0),Ord_2),PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=1)).Sort(PXL.Application.ActiveSheet.Columns(XL_String_To_Number(Sort_1)+0),Ord_1)
		PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=Head)).Sort(PXL.Application.ActiveSheet.Columns(XL_String_To_Number(Sort_2)+0),Ord_2),PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=Head)).Sort(PXL.Application.ActiveSheet.Columns(XL_String_To_Number(Sort_1)+0),Ord_1) ;suggested by Dink G.
	}

;***********Sort by Row*****https://docs.microsoft.com/en-us/office/vba/api/Excel.Range.Sort**************
XL_Sort_Rows(PXL,RG,Sort_Row:="",Ord:="A"){
		/*
			StringUpper,Ord,Ord
			IfEqual, Ord,A,SetEnv,Ord,1 ;Ascending
			IfEqual, Ord,D,SetEnv,Ord,2 ;Descending
		*/
		Ord:=Ord="A"?1:2
		PXL.Range(RG).Sort(PXL.rows(Sort_Row),Ord,,,,,,,,,2) ;the last 2 tells it to sort by rows instead of columns
	}

;********************Text to Column / Parse strings in Excel***********************************
;~ XL_Text_to_Column(XL,"A1","B1",Tab:=1,Semicolon:=1,Comma:=1,Space:=0,Other:=1,"|")
XL_Text_to_Column(PXL,Src_RG,Dest_Cell,Tab:=0,semicolon:=0,comma:=0,space:=0,other:=0,Other_Value:=""){
		PXL.Range(Src_RG).TextToColumns(PXL.range(Dest_Cell),1,1,0,tab,semicolon,comma,space,other,Other_Value)
}


;***********************Auto filter********************************.
;***********************Clear Auto filter********************************.
;~ XL_Filter_Clear_AutoFilter(XL)
XL_Filter_Clear_AutoFilter(PXL){
		PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=0)).AutoFilter ;Clear autofilter
}

;***********Add filters*******************
;~ XL_Filter_Turn_On(XL,"A:G")
XL_Filter_Turn_On(PXL,Col_RG:=""){
		CoL_RG:=(RG)?(RG):(XL_Used_RG(PXL,0)) ;If Range not provided, default to used range
		PXL.Application.ActiveSheet.Range(COL_RG).AutoFilter ;Clear autofilter
}
;***********************Filter Used Range********************************.
;~ XL_Filter_Column(XL,Filt_Col:="a",FilterA:="joe",FilterB:="king")
XL_Filter_Column(PXL,Filt_Col:="",FilterA:="",FilterB:=""){
		PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=0)).AutoFilter ;Clear autofilter
		PXL.Application.ActiveSheet.Range(XL_Used_RG(PXL,Header:=0)).AutoFilter(XL_String_To_Number(Filt_Col),FilterA,2,FilterB)
}
;********************Get cell from specific worksheet / named worksheet***********************************
XL_Get_Value_On_Specific_Worksheet(PXL,Cell,Worksheet=""){
		if (Worksheet)
			return PXL.Worksheets(Worksheet).Range(Cell).Value
		Return PXL.Application.ActiveSheet.Range(Cell).Value
}

;********************Set cell from specific worksheet / named worksheet***********************************
XL_Set_Value_On_Specific_Worksheet(PXL,Cell,Value,Worksheet:=""){
	if ( Worksheet)
		PXL.Worksheets(Worksheet).Range(Cell).Value:=Value
		Else PXL.Application.ActiveSheet.Range(Cell).Value:=Value

}
;********************Get selected range (set absolute to 1 if you want $)***********************************
;~ Range:=XL_Get_Selected_Range(XL,0)
	XL_Get_Selected_Range(PXL,Absolute:=0){
		if Absolute
			Address:=PXL.Selection.address ;;~  Selected range with $ in them
		Else
			Address:=PXL.Selection.address(0,0) ;;Selected range without $ in them
		return Address
}
;********************Get First selected Column***********************************
;~ XL_Get_First_Selected_Col(XL)
XL_Get_First_Selected_Col(PXL){
		return XL_Col_To_Char(PXL.Selection.column)
}

;********************Get first selected row***********************************
XL_Get_First_Selected_Row(PXL){
		return PXL.Selection.row
}
;  *******************************************************
;**************************File********************************
;  *******************************************************.
;~ XL:=XL_Start_Get(1,1) ;store pointer to Excel Application in XL
;~ XL:=XL_Start_Get(1,0) ;store pointer to Excel- start off hidden
XL_Start_Get(Vis:=1,Add_Blank_Worksheet:=1){
		Try {
			PXL := ComObjActive("Excel.Application") ;handle
			PXL.Visible := Vis
		}
		Catch{
			PXL := ComObjCreate("Excel.Application") ;handle
			PXL.Visible := Vis ; 1=Visible/Default 0=hidden
			If (Add_Blank_Worksheet)
				PXL.Workbooks.Add()
		}
		PXL:=XL_Handle(1)
		Return,PXL
}
;***********************Open********************************.
;***********************open excel********************************.
;~ XL_Open(XL,Vis:=1,Try:=1,Path:="B:\Americas.xlsx") ;XL is pointer to workbook, Vis=0 for hidden Try=0 for new Excel
Xl_Open(PXL,vis:=1,Path:=""){
	Try PXL := ComObjActive("Excel.Application") ;handle
	Catch
		PXL := ComObjCreate("Excel.Application") ;handle

	PXL.Visible := vis ;1=Visible/Default 0=hidden
	PXL.Workbooks.Open(path) ;wrb =handle to specific workbook
	Return PXL
}
;***********Detect and opens Tab & Comma delimited, HTML, XML and Excel 2003/2007 with pre-set defaults********************************.
;~ XL_Multi_Opener(XL,FullFileName:="C:\Diet.txt")
;~ XL_Multi_Opener(XL,FullFileName:="C:\Users\Joe\Downloads\Roofers_6.csv")
;~ XL_Multi_Opener(XL,FullFileName:="C:\Users\Joe\Dropbox\diet.xlsx")
;~ XL_Multi_Opener(XL,FullFileName:="C:\Users\Joe\Dropbox\Custom\MyDocs\Files\New Start.html")
;~ XL_Multi_Opener(XL,FullFileName:="B:\Progs\AutoHotkey_L\TI\Engage\API\Mailings Feb 01, 2013.xlsx")
;~ XL_Multi_Opener(XL,FullFileName:="B:\Progs\AutoHotkey_L\TI\Engage\API\mailing.xml")
XL_Multi_Opener(PXL,FullFileName=""){
		Ext := RegExReplace(FullFileName,"(.*)\.(\w{3,4})", "$L2") ;grab Extension and Lowercase it
		If (EXT="txt") or (EXT="txt") or (Ext="csv") or (Ext="tab"){
			TabD:="False", csvD:="False"
			IfEqual,ext,txt, SetEnv, tabD, True ;Sets tabD to 1 if extension is txt
			IfEqual,ext,tsv, SetEnv, tabD, True ;Sets tabD to 1 if extension is txt
			IfEqual,ext,csv, SetEnv, csvD, True ;Sets csvD to 1 if extension is csv
			SafeArray := ComObjArray(0xC,2,2)
			SafeArray[0, 0] := 1    ; Column Number
			SafeArray[0, 1] := 2    ; xlTextFormat
			SafeArray[1, 0] := 2    ; Column Number
			SafeArray[1, 1] := 1    ; xlGeneralFormat

			PXL.Workbooks.OpenText(FullFileName,origin:=65001,StartRow:=1,DataType:=1,TextQualifier:=1,ConsecutiveDelimiter:=False,Tab:=TabD,Semicolon:=False,Comma:=csvD,Space:=False,Other:=False,,SafeArray,,,True)
		;~ PXL.Application.Workbooks.OpenText(FullFileName), ;origin:=65001, StartRow:=1, DataType:=1, TextQualifier:=1, ConsecutiveDelimiter:=False, Tab:=tabD, Semicolon:=False, Comma:=csvD, Space:=False, Other:=False, FieldInfo:=Array(Array(1, 1), Array(2, 1)), TrailingMinusNumbers:=True
		;~  PXL.Application.Workbooks.OpenText(FullFileName,origin:=65001, StartRow:=1, DataType:=1, TextQualifier:=1, ConsecutiveDelimiter:=False, Tab:=tabD, Semicolon:=False, Comma:=csvD, Space:=False, Other:=False, FieldInfo:=Array(Array(1, 1), Array(2, 1)), TrailingMinusNumbers:=True)
		} Else if (Ext="xml"){
			PXL.Application.Workbooks.OpenXML(FullFileName, 1, 2) ;.LoadOption.2 ;import xml file
		} Else If (Ext contains xls,htm) {
			PXL.Application.Workbooks.Open(FullFileName) ;Opens Excel 2003,2007 and html
}}
;***********************Save as********************************.
;~  XL_Save(Wrb,File:="C:\try",Format:="2007",WarnOverWrite:=0) ;2007
;~ XL_Save(Wrb,File:="C:\try",Format:="2007",WarnOverWrite:=0) ;2007 format no warn on overwrite
;~ XL_Save(Wrb,File:="C:\try",Format:="CSV",WarnOverWrite:=1) ;CSV format warn on overwrite
;~ XL_Save(Wrb,File:="C:\try",Format:="TAB",WarnOverWrite:=0) ;Tab delimited no warn on overwrite
XL_Save(PXL,File="",Format="2007",WarnOverWrite=0){
		PXL.Application.DisplayAlerts := WarnOverWrite ;doesn't ask if I care about overwriting the file
		IfEqual,Format,TAB,SetEnv,Format,-4158 ;Tab
		IfEqual,Format,CSV,SetEnv,Format,6 ;CSV
		IfEqual,Format,2003,SetEnv,Format,56 ;2003 format
		IfEqual,Format,2007,SetEnv,Format,51 ;2007 format
		PXL.Application.ActiveWorkbook.Saveas(File, Format) ;save it
		PXL.Application.DisplayAlerts := true ;Turn back on warnings
}
;***********************Quit********************************.
XL_Quit(ByRef PXL){
		PXL.Application.Quit
		PXL:=""
}

;***********Create a new workbook*******************
;~  XL_Create_New_Workbook(XL)
XL_Create_New_Workbook(PXL){
		PXL.Workbooks.Add() ;create new workbook
}

;***********************MRU*********************************.
;~ XL_Handle(XL,1) ;1=Application 2=Workbook 3=Worksheet
;~ MRU(FileName:="")
XL_MRU(PXL,FileName=""){
	PXL.RecentFiles.Add(FileName) ;adds file to recently accessed file list
	mruList := []
	For file in ComObj("Excel.Application").RecentFiles
		if  (A_Index <> 1)
			mruList.Insert(file.name)
	mruList.Insert(RegExReplace(Filename,"^[A-Z]:")) ;adds to MRU list
}
;***********close workbook*******************
;~XL.Close_Workbook(1) ;close need pointer to workbook
;~ XL_Close_Workbook(XL,"B:\Tracts")
XL_Close_Workbook(PXL,File_Path=""){
		If (Workbook)
			PXL.Workbooks(File_Path).Close
		Else PXL.ActiveWorkbook.Close
}

;********************Good examples***********************************
;~ https://excel.officetuts.net/en/vba/deleting-a-row-with-vba

;~ XL_ListWorkbooks() ;Get a list of all Active Excel Instances borrowed from Jethrow and Tre4shunter https://github.com/tre4shunter/XLFunctions/
XL_ListWorkbooks(){
	wbObj:=[], i=1
	for name, obj in GetActiveObjects()
		if (ComobjType(obj, "Name") = "_Workbook"){
			splitpath,name,oFN
			wbObj[i++] := oFN
		}
	return wbObj
}

GetActiveObjects(Prefix:="", CaseSensitive:=false) {
		objects := {}
		DllCall("ole32\CoGetMalloc", "uint", 1, "ptr*", malloc) ; malloc: IMalloc
		DllCall("ole32\CreateBindCtx", "uint", 0, "ptr*", bindCtx) ; bindCtx: IBindCtx
		DllCall(NumGet(NumGet(bindCtx+0)+8*A_PtrSize), "ptr", bindCtx, "ptr*", rot) ; rot: IRunningObjectTable
		DllCall(NumGet(NumGet(rot+0)+9*A_PtrSize), "ptr", rot, "ptr*", enum) ; enum: IEnumMoniker
		while DllCall(NumGet(NumGet(enum+0)+3*A_PtrSize), "ptr", enum, "uint", 1, "ptr*", mon, "ptr", 0) = 0 { ; mon: IMoniker
			DllCall(NumGet(NumGet(mon+0)+20*A_PtrSize), "ptr", mon, "ptr", bindCtx, "ptr", 0, "ptr*", pname) ; GetDisplayName
			name := StrGet(pname, "UTF-16")
			DllCall(NumGet(NumGet(malloc+0)+5*A_PtrSize), "ptr", malloc, "ptr", pname) ; Free
			if InStr(name, Prefix, CaseSensitive) = 1 {
				DllCall(NumGet(NumGet(rot+0)+6*A_PtrSize), "ptr", rot, "ptr", mon, "ptr*", punk) ; GetObject
				if (pdsp := ComObjQuery(punk, "{00020400-0000-0000-C000-000000000046}"))   ; Wrap the pointer as IDispatch if available, otherwise as IUnknown.
					obj := ComObject(9, pdsp, 1), ObjRelease(punk)
				else
					obj := ComObject(13, punk, 1)
				objects[SubStr(name, StrLen(Prefix) + 1)] := obj	  ; Store it in the return array by suffix.
			}
			ObjRelease(mon)
		}
		ObjRelease(enum)
		ObjRelease(rot)
		ObjRelease(bindCtx)
		ObjRelease(malloc)
		return objects
}

;***********Named Cells thanks to Ryan Wells for the suggestion*******************
;***********Set name of range / Cell*******************
;~  Xl.Range("A1").name :="duh" ;Set a name. Not case sensitive
;~  XL_Name_Range(XL,"A1","Ryan")
XL_Name_Range(PXL,RG,Name){
	PXL.Range(RG).name :=Name
}
;***********Delete name for a range*******************
;~  XL_Name_Delete_Name(XL,"Ryan")
XL_Name_Delete_Name(PXL,Name){
	PXL.Names(Name).Delete ;Delete a name
}

;***********Get name of range*******************
;~  MyName:=XL_Name_GetName(XL,"A1")
XL_Name_GetName(PXL,RG){
	Return PXL.Range(RG).name.name ;Get the name of a cell
}

;***********Return content from range based on a name*******************
;~  duh:=XL_Name_GetData_in_Range(XL,"A1",0)
XL_Name_GetData_in_Range(PXL,RG,Type=0){
	If (Type)
		Return PXL.Evaluate(RG).text
	else
		Return PXL.Evaluate(RG).Value ;Get the text in a named cell/range
}

;***********Playing with Paths*******************
;~ results:=XL_Paths(XL)
XL_Paths(PXL,RG:="A1"){
	Obj:={} ;Create object for returning information
	SplitPath,% PXL.ActiveWorkbook.FullName,FileName,Directory,Extension,NameNoExt,Drive
	Obj.FileName:=FileName
	Obj.Dir:=Directory
	Obj.Ext:=Extension
	Obj.NameNoExt:=NameNoExt
	Obj.Drive:=Drive
	Obj.AppName:=PXL.Name ;application name
	Obj.FullPathFileName:=PXL.ActiveWorkbook.FullName ;Full path to file
	;~ Obj.FileName:=PXL.ActiveWorkbook.Name ;file name already found above but you could use this directly
	Obj.UserName:=PXL.UserName ;Get username
	Obj.WorksheetFromRange:=PXL.Range(RG).Parent.Name
	Obj.WorkbookFromRange:=PXL.Range(RG).Parent.Parent.Name
	Obj.LastAuthor:=PXL.ActiveWorkbook.BuiltinDocumentProperties("Last author").Value
	return obj
}

;********************Pulling Excel properties***********************************
;~ Props:=XL_Properties(XL) ;Call function
;~ for k, v in Props
	;~ data.= "key: " k "`t`tValue: " v "`n"
;~ MsgBox % data
XL_Properties(PXL){
	Obj:={} ;Create object for returning information
	Try For Prop in PXL.ActiveWorkbook.BuiltinDocumentProperties {
		Obj[Prop.Name] := Prop.Value
	}
	return Obj
}
;------------------------------------------------------------------------------
; COM.ahk Standard Library
; by Sean
; http://www.autohotkey.com/forum/topic22923.html
;------------------------------------------------------------------------------

COM_Init(bUn = "")
{
	Static	h
	Return	(bUn&&!h:="")||h==""&&1==(h:=DllCall("ole32\OleInitialize","Uint",0))?DllCall("ole32\OleUninitialize"):0
}

COM_Term()
{
	COM_Init(1)
}

COM_VTable(ppv, idx)
{
	Return	NumGet(NumGet(1*ppv)+4*idx)
}

COM_QueryInterface(ppv, IID = "")
{
	If	DllCall(NumGet(NumGet(1*ppv:=COM_Unwrap(ppv))), "Uint", ppv+0, "Uint", COM_GUID4String(IID,IID ? IID:IID=0 ? "{00000000-0000-0000-C000-000000000046}":"{00020400-0000-0000-C000-000000000046}"), "UintP", ppv:=0)=0
	Return	ppv
}

COM_AddRef(ppv)
{
	Return	DllCall(NumGet(NumGet(1*ppv:=COM_Unwrap(ppv))+4), "Uint", ppv)
}

COM_Release(ppv)
{
	If Not	IsObject(ppv)
	Return	DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv)
	Else
	{
	nRef:=	DllCall(NumGet(NumGet(COM_Unwrap(ppv))+8), "Uint", COM_Unwrap(ppv)), nRef==0 ? (ppv.prm_:=0):""
	Return	nRef
	}
}

COM_QueryService(ppv, SID, IID = "")
{
	If	DllCall(NumGet(NumGet(1*ppv:=COM_Unwrap(ppv))), "Uint", ppv, "Uint", COM_GUID4String(IID_IServiceProvider,"{6D5140C1-7436-11CE-8034-00AA006009FA}"), "UintP", psp)=0
	&&	DllCall(NumGet(NumGet(1*psp)+12), "Uint", psp, "Uint", COM_GUID4String(SID,SID), "Uint", IID ? COM_GUID4String(IID,IID):&SID, "UintP", ppv:=0)+DllCall(NumGet(NumGet(1*psp)+8), "Uint", psp)*0=0
	Return	COM_Enwrap(ppv)
}

COM_FindConnectionPoint(pdp, DIID)
{
	DllCall(NumGet(NumGet(1*pdp)+ 0), "Uint", pdp, "Uint", COM_GUID4String(IID_IConnectionPointContainer, "{B196B284-BAB4-101A-B69C-00AA00341D07}"), "UintP", pcc)
	DllCall(NumGet(NumGet(1*pcc)+16), "Uint", pcc, "Uint", COM_GUID4String(DIID,DIID), "UintP", pcp)
	DllCall(NumGet(NumGet(1*pcc)+ 8), "Uint", pcc)
	Return	pcp
}

COM_GetConnectionInterface(pcp)
{
	VarSetCapacity(DIID,16,0)
	DllCall(NumGet(NumGet(1*pcp)+12), "Uint", pcp, "Uint", &DIID)
	Return	COM_String4GUID(&DIID)
}

COM_Advise(pcp, psink)
{
	DllCall(NumGet(NumGet(1*pcp)+20), "Uint", pcp, "Uint", psink, "UintP", nCookie)
	Return	nCookie
}

COM_Unadvise(pcp, nCookie)
{
	Return	DllCall(NumGet(NumGet(1*pcp)+24), "Uint", pcp, "Uint", nCookie)
}

COM_Enumerate(penum, ByRef Result, ByRef vt = "")
{
	VarSetCapacity(varResult,16,0)
	If (0 =	hr:=DllCall(NumGet(NumGet(1*penum:=COM_Unwrap(penum))+12), "Uint", penum, "Uint", 1, "Uint", &varResult, "UintP", 0))
	Result:=(vt:=NumGet(varResult,0,"Ushort"))=9||vt=13?COM_Enwrap(NumGet(varResult,8),vt):vt=8||vt<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0?StrGet(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8)
	Return	hr
}

COM_Invoke(pdsp,name="",prm0="vT_NoNe",prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
{
	pdsp :=	COM_Unwrap(pdsp)
	If	name=
	Return	DllCall(NumGet(NumGet(1*pdsp)+8),"Uint",pdsp)
	If	name contains .
	{
		SubStr(name,1,1)!="." ? name.=".":name:=SubStr(name,2) . "."
	Loop,	Parse,	name, .
	{
	If	A_Index=1
	{
		name :=	A_LoopField
		Continue
	}
	Else If	name not contains [,(
		prmn :=	""
	Else If	InStr("])",SubStr(name,0))
	Loop,	Parse,	name, [(,'")]
	If	A_Index=1
		name :=	A_LoopField
	Else	prmn :=	A_LoopField
	Else
	{
		name .=	"." . A_LoopField
		Continue
	}
	If	A_LoopField!=
		pdsp:=	COM_Invoke(pdsp,name,prmn!="" ? prmn:"vT_NoNe"),name:=A_LoopField
	Else	Return	prmn!=""?COM_Invoke(pdsp,name,prmn,prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8):COM_Invoke(pdsp,name,prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8,prm9)
	}
	}
	Static	varg,namg,iidn,varResult,sParams
	VarSetCapacity(varResult,64,0),sParams?"":(sParams:="0123456789",VarSetCapacity(varg,160,0),VarSetCapacity(namg,88,0),VarSetCapacity(iidn,16,0)),mParams:=0,nParams:=10,nvk:=3
	Loop, 	Parse,	sParams
	If	(prm%A_LoopField%=="vT_NoNe")
	{
	 	nParams:=A_Index-1
		Break
	}
	Else If	prm%A_LoopField% is integer
		NumPut(SubStr(prm%A_LoopField%,1,1)="+"?9:prm%A_LoopField%=="-0"?(prm%A_LoopField%:=0x80020004)*0+10:3,NumPut(prm%A_LoopField%,varg,168-16*A_Index),-12)
	Else If	IsObject(prm%A_LoopField%)
		typ:=prm%A_LoopField%["typ_"],prm:=prm%A_LoopField%["prm_"],typ+0==""?(NumPut(&_nam_%A_LoopField%:=typ,namg,84-4*mParams++),typ:=prm%A_LoopField%["nam_"]+0==""?prm+0==""||InStr(prm,".")?8:3:prm%A_LoopField%["nam_"]):"",NumPut(typ==8?COM_SysString(prm%A_LoopField%,prm):prm,NumPut(typ,varg,160-16*A_Index),4)
	Else	NumPut(COM_SysString(prm%A_LoopField%,prm%A_LoopField%),NumPut(8,varg,160-16*A_Index),4)
	If	nParams
		SubStr(name,0)="="?(name:=SubStr(name,1,-1),nvk:=12,NumPut(-3,namg,4)):"",NumPut(nvk==12?1:mParams,NumPut(nParams,NumPut(&namg+4,NumPut(&varg+160-16*nParams,varResult,16))))
	Global	COM_HR, COM_LR:=""
	If	(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+20),"Uint",pdsp,"Uint",&iidn,"Uint",NumPut(&name,namg,84-4*mParams)-4,"Uint",1+mParams,"Uint",1024,"Uint",&namg,"Uint"))=0&&(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",NumGet(namg),"Uint",&iidn,"Uint",1024,"Ushort",nvk,"Uint",&varResult+16,"Uint",&varResult,"Uint",&varResult+32,"Uint",0,"Uint"))!=0&&nParams&&nvk<4&&NumPut(-3,namg,4)&&(COM_LR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",NumGet(namg),"Uint",&iidn,"Uint",1024,"Ushort",12,"Uint",NumPut(1,varResult,28)-16,"Uint",0,"Uint",0,"Uint",0,"Uint"))=0
		COM_HR:=0
	Global	COM_VT:=NumGet(varResult,0,"Ushort")
	Return	COM_HR=0?COM_VT>1?COM_VT=9||COM_VT=13?COM_Enwrap(NumGet(varResult,8),COM_VT):COM_VT=8||COM_VT<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0?StrGet(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8):"":COM_Error(COM_HR,COM_LR,&varResult+32,name)
}

COM_InvokeSet(pdsp,name,prm0,prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
{
	Return	COM_Invoke(pdsp,name "=",prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8,prm9)
}

COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
{
	Critical
	If	A_EventInfo = 6
		hr:=DllCall(NumGet(NumGet(0+p:=NumGet(this+8))+28),"Uint",p,"Uint",prm1,"UintP",pname,"Uint",1,"UintP",0),hr==0?(sfn:=StrGet(this+40) . StrGet(pname),COM_SysFreeString(pname),%sfn%(prm5,this,prm6)):""
	Else If	A_EventInfo = 5
		hr:=DllCall(NumGet(NumGet(0+p:=NumGet(this+8))+40),"Uint",p,"Uint",prm2,"Uint",prm3,"Uint",prm5)
	Else If	A_EventInfo = 4
		NumPut(0*hr:=0x80004001,prm3+0)
	Else If	A_EventInfo = 3
		NumPut(0,prm1+0)
	Else If	A_EventInfo = 2
		NumPut(hr:=NumGet(this+4)-1,this+4)
	Else If	A_EventInfo = 1
		NumPut(hr:=NumGet(this+4)+1,this+4)
	Else If	A_EventInfo = 0
		COM_IsEqualGUID(this+24,prm1)||InStr("{00020400-0000-0000-C000-000000000046}{00000000-0000-0000-C000-000000000046}",COM_String4GUID(prm1)) ? NumPut(NumPut(NumGet(this+4)+1,this+4)-8,prm2+0):NumPut(0*hr:=0x80004002,prm2+0)
	Return	hr
}

COM_DispGetParam(pDispParams, Position = 0, vt = 8)
{
	VarSetCapacity(varResult,16,0)
	DllCall("oleaut32\DispGetParam", "Uint", pDispParams, "Uint", Position, "Ushort", vt, "Uint", &varResult, "UintP", nArgErr)
	Return	(vt:=NumGet(varResult,0,"Ushort"))=8?StrGet(NumGet(varResult,8)) . COM_VariantClear(&varResult):vt=9||vt=13?COM_Enwrap(NumGet(varResult,8),vt):NumGet(varResult,8)
}

COM_DispSetParam(val, pDispParams, Position = 0, vt = 8)
{
	Return	NumPut(vt=8?COM_SysAllocString(val):vt=9||vt=13?COM_Unwrap(val):val,NumGet(NumGet(pDispParams+0)+(NumGet(pDispParams+8)-Position)*16-8),0,vt=11||vt=2 ? "short":"int")
}

COM_Error(hr = "", lr = "", pei = "", name = "")
{
	Static	bDebug:=1
	If Not	pei
	{
	bDebug:=hr
	Global	COM_HR, COM_LR
	Return	COM_HR&&COM_LR ? COM_LR<<32|COM_HR:COM_HR
	}
	Else If	!bDebug
	Return
	hr ? (VarSetCapacity(sError,1022),VarSetCapacity(nError,62),DllCall("kernel32\FormatMessage","Uint",0x1200,"Uint",0,"Uint",hr<>0x80020009?hr:(bExcep:=1)*(hr:=NumGet(pei+28))?hr:hr:=NumGet(pei+0,0,"Ushort")+0x80040200,"Uint",0,"str",sError,"Uint",512,"Uint",0),DllCall("kernel32\FormatMessage","Uint",0x2400,"str","0x%1!p!","Uint",0,"Uint",0,"str",nError,"Uint",32,"UintP",hr)):sError:="No COM Dispatch Object!`n",lr?(VarSetCapacity(sError2,1022),VarSetCapacity(nError2,62),DllCall("kernel32\FormatMessage","Uint",0x1200,"Uint",0,"Uint",lr,"Uint",0,"str",sError2,"Uint",512,"Uint",0),DllCall("kernel32\FormatMessage","Uint",0x2400,"str","0x%1!p!","Uint",0,"Uint",0,"str",nError2,"Uint",32,"UintP",lr)):""
	MsgBox, 260, COM Error Notification, % "Function Name:`t""" . name . """`nERROR:`t" . sError . "`t(" . nError . ")" . (bExcep ? SubStr(NumGet(pei+24) ? DllCall(NumGet(pei+24),"Uint",pei) : "",1,0) . "`nPROG:`t" . StrGet(NumGet(pei+4)) . COM_SysFreeString(NumGet(pei+4)) . "`nDESC:`t" . StrGet(NumGet(pei+8)) . COM_SysFreeString(NumGet(pei+8)) . "`nHELP:`t" . StrGet(NumGet(pei+12)) . COM_SysFreeString(NumGet(pei+12)) . "," . NumGet(pei+16) : "") . (lr ? "`n`nERROR2:`t" . sError2 . "`t(" . nError2 . ")" : "") . "`n`nWill Continue?"
	IfMsgBox, No, Exit
}

COM_CreateIDispatch()
{
	Static	IDispatch
	If Not	VarSetCapacity(IDispatch)
	{
		VarSetCapacity(IDispatch,28,0),   nParams=3112469
		Loop,   Parse,   nParams
		NumPut(RegisterCallback("COM_DispInterface","",A_LoopField,A_Index-1),IDispatch,4*(A_Index-1))
	}
	Return &IDispatch
}

COM_GetDefaultInterface(pdisp)
{
	DllCall(NumGet(NumGet(1*pdisp) +12), "Uint", pdisp , "UintP", ctinf)
	If	ctinf
	{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	DllCall(NumGet(NumGet(1*pdisp)+ 0), "Uint", pdisp, "Uint" , pattr, "UintP", ppv)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	If	ppv
	DllCall(NumGet(NumGet(1*pdisp)+ 8), "Uint", pdisp),	pdisp := ppv
	}
	Return	pdisp
}

COM_GetDefaultEvents(pdisp)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	VarSetCapacity(IID,16),DllCall("kernel32\RtlMoveMemory","Uint",&IID,"Uint",pattr,"Uint",16)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Loop, %	DllCall(NumGet(NumGet(1*ptlib)+12), "Uint", ptlib)
	{
		DllCall(NumGet(NumGet(1*ptlib)+20), "Uint", ptlib, "Uint", A_Index-1, "UintP", TKind)
		If	TKind <> 5
			Continue
		DllCall(NumGet(NumGet(1*ptlib)+16), "Uint", ptlib, "Uint", A_Index-1, "UintP", ptinf)
		DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
		nCount:=NumGet(pattr+48,0,"Ushort")
		DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
		Loop, %	nCount
		{
			DllCall(NumGet(NumGet(1*ptinf)+36), "Uint", ptinf, "Uint", A_Index-1, "UintP", nFlags)
			If	!(nFlags & 1)
				Continue
			DllCall(NumGet(NumGet(1*ptinf)+32), "Uint", ptinf, "Uint", A_Index-1, "UintP", hRefType)
			DllCall(NumGet(NumGet(1*ptinf)+56), "Uint", ptinf, "Uint", hRefType , "UintP", prinf)
			DllCall(NumGet(NumGet(1*prinf)+12), "Uint", prinf, "UintP", pattr)
			nFlags & 2 ? DIID:=COM_String4GUID(pattr) : bFind:=COM_IsEqualGUID(pattr,&IID)
			DllCall(NumGet(NumGet(1*prinf)+76), "Uint", prinf, "Uint" , pattr)
			DllCall(NumGet(NumGet(1*prinf)+ 8), "Uint", prinf)
		}
		DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
		If	bFind
			Break
	}
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	bFind ? DIID : "{00000000-0000-0000-0000-000000000000}"
}

COM_GetGuidOfName(pdisp, Name)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf:=0
	DllCall(NumGet(NumGet(1*ptlib)+44), "Uint", ptlib, "Uint", &Name, "Uint", 0, "UintP", ptinf, "UintP", memID, "UshortP", 1)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	GUID := COM_String4GUID(pattr)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Return	GUID
}

COM_GetTypeInfoOfGuid(pdisp, GUID)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf := 0
	DllCall(NumGet(NumGet(1*ptlib)+24), "Uint", ptlib, "Uint", COM_GUID4String(GUID,GUID), "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	ptinf
}

COM_ConnectObject(pdisp, prefix = "", DIID = "")
{
	pdisp:=	COM_Unwrap(pdisp)
	If Not	DIID
		0+(pconn:=COM_FindConnectionPoint(pdisp,"{00020400-0000-0000-C000-000000000046}")) ? (DIID:=COM_GetConnectionInterface(pconn))="{00020400-0000-0000-C000-000000000046}" ? DIID:=COM_GetDefaultEvents(pdisp):"":pconn:=COM_FindConnectionPoint(pdisp,DIID:=COM_GetDefaultEvents(pdisp))
	Else	pconn:=COM_FindConnectionPoint(pdisp,SubStr(DIID,1,1)="{" ? DIID:DIID:=COM_GetGuidOfName(pdisp,DIID))
	If	!pconn||!ptinf:=COM_GetTypeInfoOfGuid(pdisp,DIID)
	{
		MsgBox, No Event Interface Exists!
		Return
	}
	NumPut(pdisp,NumPut(ptinf,NumPut(1,NumPut(COM_CreateIDispatch(),0+psink:=COM_CoTaskMemAlloc(40+nSize:=StrLen(prefix)*2+2)))))
	DllCall("kernel32\RtlMoveMemory","Uint",psink+24,"Uint",COM_GUID4String(DIID,DIID),"Uint",16)
	DllCall("kernel32\RtlMoveMemory","Uint",psink+40,"Uint",&prefix,"Uint",nSize)
	NumPut(COM_Advise(pconn,psink),NumPut(pconn,psink+16))
	Return	psink
}

COM_DisconnectObject(psink)
{
	Return	COM_Unadvise(NumGet(psink+16),NumGet(psink+20))=0 ? (0,COM_Release(NumGet(psink+16)),COM_Release(NumGet(psink+8)),COM_CoTaskMemFree(psink)):1
}

COM_CreateObject(CLSID, IID = "", CLSCTX = 21)
{
	ppv :=	COM_CreateInstance(CLSID,IID,CLSCTX)
	Return	IID=="" ? COM_Enwrap(ppv):ppv
}

COM_GetObject(Name)
{
	COM_Init()
	If	DllCall("ole32\CoGetObject", "Uint", &Name, "Uint", 0, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)=0
	Return	COM_Enwrap(pdisp)
}

COM_GetActiveObject(CLSID)
{
	COM_Init()
	If	DllCall("oleaut32\GetActiveObject", "Uint", COM_GUID4String(CLSID,CLSID), "Uint", 0, "UintP", punk)=0
	&&	DllCall(NumGet(NumGet(1*punk)), "Uint", punk, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)+DllCall(NumGet(NumGet(1*punk)+8), "Uint", punk)*0=0
	Return	COM_Enwrap(pdisp)
}

COM_CreateInstance(CLSID, IID = "", CLSCTX = 21)
{
	COM_Init()
	If	DllCall("ole32\CoCreateInstance", "Uint", COM_GUID4String(CLSID,CLSID), "Uint", 0, "Uint", CLSCTX, "Uint", COM_GUID4String(IID,IID ? IID:IID=0 ? "{00000000-0000-0000-C000-000000000046}":"{00020400-0000-0000-C000-000000000046}"), "UintP", ppv)=0
	Return	ppv
}

COM_CLSID4ProgID(ByRef CLSID, ProgID)
{
	VarSetCapacity(CLSID,16,0)
	DllCall("ole32\CLSIDFromProgID", "Uint", &ProgID, "Uint", &CLSID)
	Return	&CLSID
}

COM_ProgID4CLSID(pCLSID)
{
	DllCall("ole32\ProgIDFromCLSID", "Uint", pCLSID, "UintP", pProgID)
	Return	StrGet(pProgID) . COM_CoTaskMemFree(pProgID)
}

COM_GUID4String(ByRef CLSID, String)
{
	VarSetCapacity(CLSID,16,0)
	DllCall("ole32\CLSIDFromString", "Uint", &String, "Uint", &CLSID)
	Return	&CLSID
}

COM_String4GUID(pGUID)
{
	VarSetCapacity(String,38*2)
	DllCall("ole32\StringFromGUID2", "Uint", pGUID, "str", String, "int", 39)
	Return	String
}

COM_IsEqualGUID(pGUID1, pGUID2)
{
	Return	DllCall("ole32\IsEqualGUID", "Uint", pGUID1, "Uint", pGUID2)
}

COM_CoCreateGuid()
{
	VarSetCapacity(GUID,16,0)
	DllCall("ole32\CoCreateGuid", "Uint", &GUID)
	Return	COM_String4GUID(&GUID)
}

COM_CoInitialize()
{
	Return	DllCall("ole32\CoInitialize", "Uint", 0)
}

COM_CoUninitialize()
{
		DllCall("ole32\CoUninitialize")
}

COM_CoTaskMemAlloc(cb)
{
	Return	DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
}

COM_CoTaskMemFree(pv)
{
		DllCall("ole32\CoTaskMemFree", "Uint", pv)
}

COM_SysAllocString(str)
{
	Return	DllCall("oleaut32\SysAllocString", "Uint", &str)
}

COM_SysFreeString(pstr)
{
		DllCall("oleaut32\SysFreeString", "Uint", pstr)
}

COM_SafeArrayDestroy(psar)
{
	Return	DllCall("oleaut32\SafeArrayDestroy", "Uint", psar)
}

COM_VariantClear(pvar)
{
		DllCall("oleaut32\VariantClear", "Uint", pvar)
}

COM_VariantChangeType(pvarDst, pvarSrc, vt = 8)
{
	Return	DllCall("oleaut32\VariantChangeTypeEx", "Uint", pvarDst, "Uint", pvarSrc, "Uint", 1024, "Ushort", 0, "Ushort", vt)
}

COM_SysString(ByRef wString, sString)
{
	VarSetCapacity(wString,4+nLen:=2*StrLen(sString))
	Return	DllCall("kernel32\lstrcpyW","Uint",NumPut(nLen,wString),"Uint",&sString)
}

COM_AccInit()
{
	Static	h
	If Not	h
	COM_Init(), h:=DllCall("kernel32\LoadLibrary","str","oleacc")
}

COM_AccTerm()
{
	COM_Term()
}

COM_AccessibleChildren(pacc, cChildren, ByRef varChildren)
{
	VarSetCapacity(varChildren,cChildren*16,0)
	If	DllCall("oleacc\AccessibleChildren", "Uint", COM_Unwrap(pacc), "Uint", 0, "Uint", cChildren+0, "Uint", &varChildren, "UintP", cChildren:=0)=0
	Return	cChildren
}

COM_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_="")
{
	COM_AccInit(), VarSetCapacity(varChild,16,0)
	If	DllCall("oleacc\AccessibleObjectFromEvent", "Uint", hWnd, "Uint", idObject, "Uint", idChild, "UintP", pacc, "Uint", &varChild)=0
	Return	COM_Enwrap(pacc), _idChild_:=NumGet(varChild,8)
}

COM_AccessibleObjectFromPoint(x, y, ByRef _idChild_="")
{
	COM_AccInit(), VarSetCapacity(varChild,16,0)
	If	DllCall("oleacc\AccessibleObjectFromPoint", "int", x, "int", y, "UintP", pacc, "Uint", &varChild)=0
	Return	COM_Enwrap(pacc), _idChild_:=NumGet(varChild,8)
}

COM_AccessibleObjectFromWindow(hWnd, idObject=-4, IID = "")
{
	COM_AccInit()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Uint", hWnd, "Uint", idObject, "Uint", COM_GUID4String(IID, IID ? IID : idObject&0xFFFFFFFF==0xFFFFFFF0 ? "{00020400-0000-0000-C000-000000000046}":"{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pacc)=0
	Return	COM_Enwrap(pacc)
}

COM_WindowFromAccessibleObject(pacc)
{
	If	DllCall("oleacc\WindowFromAccessibleObject", "Uint", COM_Unwrap(pacc), "UintP", hWnd)=0
	Return	hWnd
}

COM_GetRoleText(nRole)
{
	nLen:=	DllCall("oleacc\GetRoleTextW", "Uint", nRole, "Uint", 0, "Uint", 0)
	VarSetCapacity(sRole,nLen*2)
	If	DllCall("oleacc\GetRoleTextW", "Uint", nRole, "str", sRole, "Uint", nLen+1)
	Return	sRole
}

COM_GetStateText(nState)
{
	nLen:=	DllCall("oleacc\GetStateTextW", "Uint", nState, "Uint", 0, "Uint", 0)
	VarSetCapacity(sState,nLen*2)
	If	DllCall("oleacc\GetStateTextW", "Uint", nState, "str", sState, "Uint", nLen+1)
	Return	sState
}

COM_AtlAxWinInit(Version = "")
{
	Static	h
	If Not	h
	COM_Init(), h:=DllCall("kernel32\LoadLibrary","str","atl" . Version), DllCall("atl" . Version . "\AtlAxWinInit")
}

COM_AtlAxWinTerm(Version = "")
{
	COM_Term()
}

COM_AtlAxGetHost(hWnd, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxGetHost", "Uint", hWnd, "UintP", punk)=0
	Return	COM_Enwrap(COM_QueryInterface(punk)+COM_Release(punk)*0)
}

COM_AtlAxGetControl(hWnd, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxGetControl", "Uint", hWnd, "UintP", punk)=0
	Return	COM_Enwrap(COM_QueryInterface(punk)+COM_Release(punk)*0)
}

COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxAttachControl", "Uint", punk:=COM_QueryInterface(pdsp,0), "Uint", hWnd, "Uint", COM_AtlAxWinInit(Version))+COM_Release(punk)*0=0
	Return	COM_Enwrap(pdsp)
}

COM_AtlAxCreateControl(hWnd, Name, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxCreateControl", "Uint", &Name, "Uint", hWnd, "Uint", 0, "Uint", COM_AtlAxWinInit(Version))=0
	Return	COM_AtlAxGetControl(hWnd,Version)
}

COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
{
	Return	DllCall("user32\CreateWindowEx", "Uint",0x200, "str", "AtlAxWin" . Version, "Uint", Name?&Name:0, "Uint", 0x54000000, "int", l, "int", t, "int", w, "int", h, "Uint", hWnd, "Uint", 0, "Uint", 0, "Uint", COM_AtlAxWinInit(Version))
}

COM_AtlAxGetContainer(pdsp, bCtrl = "")
{
	DllCall(NumGet(NumGet(1*pdsp:=COM_Unwrap(pdsp))), "Uint", pdsp, "Uint", COM_GUID4String(IID_IOleWindow,"{00000114-0000-0000-C000-000000000046}"), "UintP", pwin)
	DllCall(NumGet(NumGet(1*pwin)+12), "Uint", pwin, "UintP", hCtrl)
	DllCall(NumGet(NumGet(1*pwin)+ 8), "Uint", pwin)
	Return	bCtrl?hCtrl:DllCall("user32\GetParent", "Uint", hCtrl)
}

COM_ScriptControl(sCode, sEval = "", sName = "", Obj = "", bGlobal = "")
{
	oSC:=COM_CreateObject("ScriptControl"), oSC.Language(sEval+0==""?"VBScript":"JScript"), sName&&Obj?oSC.AddObject(sName,Obj,bGlobal):""
	Return	sEval?oSC.Eval(sEval+0?sCode:sEval oSC.AddCode(sCode)):oSC.ExecuteStatement(sCode)
}

COM_Parameter(typ, prm = "", nam = "")
{
	Return	IsObject(prm)?prm:Object("typ_",typ,"prm_",prm,"nam_",nam)
}

COM_Enwrap(obj, vt = 9)
{
	Static	base
	Return	IsObject(obj)?obj:Object("prm_",obj,"typ_",vt,"base",base?base:base:=Object("__Delete","COM_Invoke","__Call","COM_Invoke","__Get","COM_Invoke","__Set","COM_InvokeSet","base",Object("__Delete","COM_Term")))
}

COM_Unwrap(obj)
{
	Return	IsObject(obj)?obj.prm_:obj
}
