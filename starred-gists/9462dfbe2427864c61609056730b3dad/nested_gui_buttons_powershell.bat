@echo off &title Nested GUI buttons example via powershell snippet by AveYo

:gui_dialog_1
set first_choices=Option 1,Option 2,Option3,Option4,Finish&set title=Simple GUI choices #1
:: Show gui dialog %1=Title %2=choices %3=outputvariable
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
:: Show gui dialog %1=Title %2=choices %3=outputvariable
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

::------------------------------------------------------------------------------------------------------------------------------
:choice
rem 1=title 2=choices 3=output_variable [button number]    [GUI buttons dialog snippet by AveYo] released under MIT License
setlocal & set "ps_Choice=$title='%~1'; $choices='%~2'.split(','); $n=$choices.length; $global:c=''; $i=1; "
set "s1=[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$f=New-Object System.Windows.Forms.Form"
set "s2=;$f.Text=$title; $f.BackColor=0xff180052; $f.Forecolor='Snow'; $f.StartPosition=4; $f.AutoSize=1; $f.FormBorderStyle=3;"
set "s3=foreach($l in $choices){ $b=New-Object System.Windows.Forms.Button; $b.Text=$l; $b.Name=$n-$i; $b.cursor='Hand';"
set "s4= $b.Location='8,'+(32*$i);$b.Margin='8,4,8,4';$b.MinimumSize='320,20';$b.add_Click({$global:c=$this.Text;$f.Close()});"
set "s5= $f.Controls.Add($b); $i++ }; $f.AcceptButton=$f.Controls[0]; $f.CancelButton=$f.Controls[-1]; $f.MaximizeBox=0; "
set "s6=$f.Add_Shown({$f.Activate()}); $null=$f.ShowDialog(); if($global:c -ne ''){write-host $global:c}"
for /l %%# in (1,1,6) do call set "ps_Choice=%%ps_Choice%%%%s%%#:"=\"%%"
endlocal & for /f "tokens=* delims=" %%# in ('powershell -noprofile -c "%ps_Choice%"') do set "%~3=%%#"
exit/b
::------------------------------------------------------------------------------------------------------------------------------ 