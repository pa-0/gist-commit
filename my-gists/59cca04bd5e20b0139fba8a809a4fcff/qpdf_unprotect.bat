@echo off
@setlocal enableExtensions disableDelayedExpansion
REM support UTF8 characters print for qpdf error output strings
@chcp 65001 > nul
REM batch command use path prefixed by \\?\c:\path to bypass file path size max limit
REM https://superuser.com/a/825233
set "arg1=%~1"
set "arg2=%~2"
set "arg3=%~3"
@setlocal enableDelayedExpansion
set "CURRENT_RUNNING_DIR=%cd%"

echo Source code is here : https://gist.github.com/StudioEtrange/44a2fb333f4d682ab72634c3dd9e472f
echo Will remove owner password on pdf files to allow modification
echo Will modfiy specified file or all files in folder and subfolder.
echo Need tool 'qpdf' installed https://github.com/qpdf/qpdf
echo Usage : %~nx0 "qpdf_exe_full_path" "pdf_files_or_folder_to_unprotect" "<OPTIONS>"
echo NOTE : support filepath with special character "!" inside
echo Option list :
echo 	BACKUP : backup the transformed files as .backup.pdf files

echo Sample : %~nx0 "T:\TOOLS\qpdf - pdf password remover opensource\qpdf-11.9.1-mingw64\bin\qpdf.exe" "T:\TO_UNPROTECT\files" "BACKUP"
echo -------
echo CALL unprotect "!arg1!" "!arg2!" "!arg3!"
call :unprotect "!arg1!" "!arg2!" "!arg3!"

@goto :end



REM qpdf option --replace-input do not work well
REM qpdf do not want to create file with .pdf extension in unknow circonstances (error : permission denied)
:unprotect
  @setlocal disableDelayedExpansion
  set "qpdfexe_path=%~1"
  set "pdf_path=%~2"
  set "backup=%~3"
  @setlocal enableDelayedExpansion

  set "extbackup=.backup.pdf"
  if "!backup!"=="BACKUP" (
	set "backup=%extbackup%"
  ) else (
	set "backup="
  )


  set "attr=%~a2"
  set "dirattr=%attr:~0,1%"

  if /I "%dirattr%"=="d" (
	cd /D "!pdf_path!"
	for /R %%p in ("*.pdf") do (
		setlocal DisableDelayedExpansion
		set "extension=%%~xp"
		set "_p=%%p"
		setlocal EnableDelayedExpansion	

		for /F "delims=" %%A in ("!_p!\.") do (
			setlocal DisableDelayedExpansion
			set "_base=%%~nA"
			setlocal EnableDelayedExpansion
			set "basename_path=!_base!"
		)
		for /F "delims=" %%A in ("!_p!\.") do (
			setlocal DisableDelayedExpansion
			set "_dir=%%~dpA"
			setlocal EnableDelayedExpansion
			set "dir_path=!_dir!"
		)

		if not "%backup%"=="" (
			echo -
			echo BACKUP !_p! to !_p!!extbackup!
			@copy /y "\\?\!_p!" "\\?\!_p!!extbackup!" >nul 2>&1
		)

		REM copy file into temp directory because there is a max limit to file path length that qpdf can read (max 260 characters)
		copy /y "\\?\!_p!" "%TEMP%\!basename_path!!extension!" >nul 2>&1

		echo -
		echo "!qpdfexe_path!" --verbose --decrypt "!_p!" "!dir_path!!basename_path!.decrypted"
		echo "!qpdfexe_path!" --verbose --decrypt "%TEMP%\!basename_path!!extension!" "%TEMP%\!basename_path!.decrypted"
		echo -
		"!qpdfexe_path!" --verbose --decrypt "%TEMP%\!basename_path!!extension!" "%TEMP%\!basename_path!.decrypted"
		
		move /y "%TEMP%\!basename_path!.decrypted" "\\?\!dir_path!!basename_path!!extension!" >nul 2>&1

		del "%TEMP%\!basename_path!!extension!" >nul 2>&1
		del "%TEMP%\!basename_path!.decrypted" >nul 2>&1
	)
  ) else (
	set "extension=%~x2"

	if "!extension!"==".pdf" (
		for /F "delims=" %%A in ("!pdf_path!\.") do (
			setlocal DisableDelayedExpansion
			set "_base=%%~nA"
			setlocal EnableDelayedExpansion
			set "basename_path=!_base!"
		)
		for /F "delims=" %%A in ("!pdf_path!\.") do (
			setlocal DisableDelayedExpansion
			set "_dir=%%~dpA"
			setlocal EnableDelayedExpansion
			set "dir_path=!_dir!"
		)

		if not "%backup%"=="" (
			echo -
			echo BACKUP !pdf_path! to !pdf_path!!extbackup!
			@copy /y "\\?\!dir_path!!basename_path!!extension!" "\\?\!dir_path!!basename_path!!extension!!extbackup!" >nul 2>&1
		)

		REM copy file into temp directory because there is a max limit to file path length that qpdf can read (max 260 characters)
		echo copy /y "\\?\!dir_path!!basename_path!!extension!" "%TEMP%\!basename_path!!extension!"
		copy /y "\\?\!dir_path!!basename_path!!extension!" "%TEMP%\!basename_path!!extension!" >nul 2>&1

		echo -
		echo "!qpdfexe_path!" --verbose --decrypt "!pdf_path!" "!dir_path!\!basename_path!.decrypted"
		echo "!qpdfexe_path!" --verbose --decrypt "%TEMP%\!basename_path!!extension!" "%TEMP%\!basename_path!.decrypted"
		echo -
		"!qpdfexe_path!" --verbose --decrypt "%TEMP%\!basename_path!!extension!" "%TEMP%\!basename_path!.decrypted"
		
		move /y "%TEMP%\!basename_path!.decrypted" "\\?\!dir_path!!basename_path!!extension!" >nul 2>&1

		del "%TEMP%\!basename_path!!extension!" >nul 2>&1
		del "%TEMP%\!basename_path!.decrypted" >nul 2>&1		
    )
  )
goto :eof


:end
@cd /D %CURRENT_RUNNING_DIR%
@echo on
