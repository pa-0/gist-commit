@echo off &title Multiple GUI choices via powershell snippet by AveYo                 &rem preview: https://i.imgur.com/JjazNR0.png
:: setup gui dialog choices
set all_choices=Option 1,Option 2,Option 3,Option4,Option5
set def_choices=Option 1,Option 2,Option5
:: Show gui dialog choices 1=title 2=all_choices 3=def_choices 4=output_variable
call :choices "Multiple GUI choices" "%all_choices%" "%def_choices%" CHOICES
:: Quit if no choice selected
if not defined CHOICES color 0c &echo  ERROR! No choice selected.. &timeout /t 20 &color 07 &exit/b
:: Print choices
echo Choices: %CHOICES% & echo.
:: Process choices
call :process "%CHOICES%"

:Done
timeout /t -1
exit/b

:"Option 1"
echo running code for %0
rem do stuff here
exit/b
:"Option 2"
echo running code for %0
rem do stuff here
exit/b
:"Option 3"
echo running code for %0
rem do stuff here
exit/b
:"Option4"
echo running code for %0
rem do stuff here
exit/b
:"Option5"
echo running code for %0
rem do stuff here
exit/b

:process %1=choices
for /f "tokens=1* delims=," %%a in ("%~1") do if %%a.==. (exit/b) else call :"%%a" &call :process "%%b"
exit/b

::---------------------------------------------------------------------------------------------------------------------------------
:choices 1=title 2=all_choices 3=def_choices 4=output_variable          GUI dialog with autosize checkboxes - outputs %CHOICES%
setlocal &set "parameters=$n='%~1'; $all='%~2'; $def='%~3'; $p='HKCU:\Environment'; $pad=32;"
set "s1=[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $f=New-Object System.Windows.Forms.Form;"
set "s2=[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing'); $f.Forecolor='Black';$f.BackColor='WhiteSmoke';"
set "s3=$r=(Get-ItemProperty $p).$n; if($r -ne $null){$opt=$r.split(',')}else{$opt=$def.split(',')}; function CLK(){ $v=@();"
set "s4=foreach($x in $cb){if($x.Checked){$v+=$x.Text}}; New-ItemProperty -Path $p -Name $n -Value $($v -join ',') -Force };"
set "s5=$BCLK=@(0, {CLK}, {foreach($z in $cb){$z.Checked=$false;if($def.split(',') -contains $z.Text){$z.Checked=$true}};CLK});"
set "s6=$i=1; $cb=foreach($l in $all.split(',')){$c=New-Object System.Windows.Forms.CheckBox; $c.Name='c$i'; $c.AutoSize=$true;"
set "s7=$c.Text=$l; $c.Location=New-Object System.Drawing.Point(($pad*2.5),(16+(($i-1)*24))); $c.BackColor='Transparent';"
set "s8=$c.add_Click({CLK}); $f.Controls.Add($c); $c; $i++; }; foreach($s in $cb){if($opt -contains $s.Text){$s.Checked=$true}};"
set "s9=$j=1; $bn=@('OK','Reset');foreach($t in $bn){ $b=New-Object System.Windows.Forms.Button; $b.BackColor='Transparent';"
set "s10=$b.Location=New-Object System.Drawing.Point(($pad*2+($j-1)*$pad*3),(32+(($i-1)*24))); $b.Margin='0,0,72,20';"
set "s11=$b.add_Click($BCLK[$j]); if ($t -eq 'OK'){$b.DialogResult=1;$f.AcceptButton=$b}; $b.Name='b$j'; $b.Text=$t;"
set "s12=$f.Controls.Add($b);$j++;}; $f.Text=$n; $f.FormBorderStyle='Fixed3D'; $f.AutoSize=$true; $f.AutoSizeMode='GrowAndShrink';"
set "s13=$f.MaximizeBox=$false; $f.StartPosition='CenterScreen'; $f.Add_Shown({$f.Activate()}); $ret=$f.ShowDialog();"
set "s14=if ($ret -ne 1) {Remove-ItemProperty -Path $p -Name $n -Force  -erroraction 'silentlycontinue' | out-null}"
set "s15=else {write-host (Get-ItemProperty -Path $p -Name $n).$n;}"
for /l %%# in (1,1,15) do call set "ps_Choices=%%ps_Choices%%%%s%%#:"=\"%%"
for /f "usebackq tokens=* delims=" %%# in (`powershell -c "%parameters% %ps_Choices%"`) do set "choices_var=%%#"
endlocal & set "%~4=%choices_var%" & exit/b &rem snippet by AveYo released under MIT License
::--------------------------------------------------------------------------------------------------------------------------------- 