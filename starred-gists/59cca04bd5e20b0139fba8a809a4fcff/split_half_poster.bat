
@setlocal enableExtensions enableDelayedExpansion
@echo off
set CURRENT_RUNNING_DIR=%cd%

echo Source code is here : https://gist.github.com/StudioEtrange/44a2fb333f4d682ab72634c3dd9e472f
echo Will split in two each poster of pdf files
echo need mupdf https://mupdf.com/
echo Usage : split_half_poster.bat "mutool_exe_full_path" "pdf_folder_to_split"
echo Sample : split_half_poster.bat "E:\WORKSPACE\mupdf-1.18.0-windows\mutool.exe" "E:\TO_SPLIT\files"
call :split "%~1" "%~2"

@goto :end



:del_folder
	if exist "%~1" (
		echo ** Deleting %~1 folder
		del /f/q "%~1" >nul 2>&1
		rmdir /s/q "%~1" >nul 2>&1
	)
goto :eof


:basename
	set "_result_basename=%~1"
	set "_path=%~2"

	for /F "delims=" %%A in ("!_path!\.") do (
		set %_result_basename%=%%~nA
	)
goto :eof

:dirname
	set "_result_dirname=%~1"
	set "_path=%~2"

	for /F "delims=" %%A in ("!_path!\.") do (
		set %_result_dirname%=%%~dpA
	)
goto :eof


:split
  set "exe_path=%~1"
  set "pdf_folderpath=%~2"
  
  call :dirname "output_path" "%pdf_folderpath%"
  call :basename "basename_path" "%pdf_folderpath%"
  set "output=%output_path%\%basename_path%_splitted"

  call :del_folder "%output%"
  mkdir "%output%"
  
  cd /D "%pdf_folderpath%"
  for %%p in ("*") do (
	set "extension=%%~xp"
	if "!extension!"==".pdf" (
		    echo "%exe_path%" poster -x 2 "%%p" "%output%\%%p"
		    "%exe_path%" poster -x 2 "%%p" "%output%\%%p"
    ) else (
		    echo copy /y "%%p" "%output%\%%p"
		    @copy /y "%%p" "%output%\%%p"
	  )
  )
goto :eof

:end
@cd /D %CURRENT_RUNNING_DIR%
@echo on

