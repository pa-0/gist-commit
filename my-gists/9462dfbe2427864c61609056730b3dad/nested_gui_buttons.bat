@echo off &title Nested GUI buttons example via mshta snippet by AveYo                &rem preview: https://i.imgur.com/bAIuIHy.png
:: v2: less flicker

:gui_dialog_1
set first_choices=Option 1,Option 2,Option3,Option4,Finish&set title=Simple GUI choices #1
:: Show gui dialog 1=Title 2=choices 3=outputvariable
call :choice "Simple GUI buttons" "%first_choices%" CHOICE
:: Quit if no choice selected
if not defined CHOICE color 0c &echo  ERROR! No choice selected.. &timeout /t 20 &color 07 &exit/b
:: Print choices
echo Choice1: %CHOICE% & echo.
:: Continue to dialog_2
goto gui_dialog_2

:gui_dialog_2
:: Process results from dialog_1
if "%CHOICE%"=="Option 1" set next_choices=Suboption 1 1,Suboption 1 2,Suboption 1 3,Back&set title=Option 1
if "%CHOICE%"=="Option 2" set next_choices=Suboption 2 1,Suboption 2 2,Back&set title=Option 2
if "%CHOICE%"=="Option3"  set next_choices=Suboption 3 1,Suboption 3 2,Suboption 3 3,Suboption 3 4,Back&set title=Option3
if "%CHOICE%"=="Option4"  call :"Option4" &goto Done no suboption
if "%CHOICE%"=="Finish"   call :"Finish"  &goto Done no suboption
:: Show gui dialog 1=Title 2=choices 3=outputvariable
call :choice "%title%" "%next_choices%" CHOICE
:: Quit if no choice selected
if not defined CHOICE color 0c &echo  ERROR! No choice selected.. &timeout /t 20 &color 07 &exit/b
:: Print choices
echo Choice2: %CHOICE% & echo.
:: Back to dialog_1
if "%CHOICE%"=="Back" goto gui_dialog_1

:: Process final choice
call :"%CHOICE%"

:Done
timeout /t -1
exit/b

:: Choice code
:"Option4"
echo running code for %0
rem do stuff here
exit/b
:"Finish"
echo running code for %0
rem do stuff here
goto :Done
:"Suboption 1 1"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 1 2"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 1 3"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 2 1"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 2 2"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 1"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 2"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 3"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 4"
echo running code for %0
rem do stuff here
exit/b

::---------------------------------------------------------------------------------------------------------------------------------
:choice
rem 1=title 2=options 3=output_variable                                          example: call :choice Choose "op1,op2,op3" result
setlocal & set "c=about:<title>%~1</title><head><script language='javascript'>window.moveTo(-200,-200);window.resizeTo(100,100);"
set "c=%c% </script><hta:application innerborder='no' sysmenu='yes' scroll='no'><style>body{background-color:#17141F;}"
set "c=%c% br{font-size:14px;vertical-align:-4px;} .button{background-color:#7D5BBE;border:2px solid #392E5C; color:white;"
set "c=%c% padding:4px 4px;text-align:center;text-decoration:none;display:inline-block;font-size:16px;cursor:pointer;"
set "c=%c% width:100%%;display:block;}</style></head><script language='javascript'>function choice(){"
set "c=%c% var opt=document.getElementById('options').value.split(','); var btn=document.getElementById('buttons');"
set "c=%c% for (o in opt){var b=document.createElement('button');b.className='button';b.onclick=function(){
set "c=%c% close(new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(this.value));};"
set "c=%c% b.appendChild(document.createTextNode(opt[o]));btn.appendChild(b);btn.appendChild(document.createElement('br'));};"
set "c=%c% btn.appendChild(document.createElement('br'));var r=window.parent.screen;"
set "c=%c% window.moveTo(r.availWidth/3,r.availHeight/6);window.resizeTo(r.availWidth/3,document.body.scrollHeight);}</script>"
set "c=%c% <body onload='choice()'><div id='buttons'/><input type='hidden' name='options' value='%~2'></body>"
for /f "usebackq tokens=* delims=" %%# in (`mshta "%c%"`) do set "choice_var=%%#"
endlocal & set "%~3=%choice_var%" & exit/b &rem snippet by AveYo released under MIT License
::-------------------------------------------------------------------------------------------------------------------------------- 