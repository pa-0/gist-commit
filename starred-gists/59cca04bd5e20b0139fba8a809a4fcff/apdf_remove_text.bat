@echo off
@setlocal enableExtensions disableDelayedExpansion
set "arg1=%~1"
set "arg2=%~2"
set "arg3=%~3"
set "arg4=%~4"
@setlocal enableDelayedExpansion
set "CURRENT_RUNNING_DIR=%cd%"

echo Source code is here : https://gist.github.com/StudioEtrange/44a2fb333f4d682ab72634c3dd9e472f
echo Will remove text from pdf inside a folder. Will modfiy specified file or all files in folder and subfolders.
echo Need tool 'a-pdf text replace' installed http://www.a-pdf.com/text-replace/index.htm
echo Usage : %~nx0 "apdf_exe_full_path" "pdf_folder_or_file" "regexp_text_to_remove" "<OPTIONS>"
echo Option list :
echo BACKUP : backup the transformed files as .backup.pdf files
echo REGEX : use the third arg as a regex to match text to remove (default active option)
echo REGEX_FILE : use the third arg as a path to file containing several regexes, one by line
echo REGEX_FILE FORMAT : these two lines will be merged into one regex "((R|r)ef)?(word)?"
echo			## a comment
echo			(R^|r)ef
echo			## another comment
echo			word


echo Sample : %~nx0 "e:\Program Files (x86)\A-PDF Text Replace\ptrcmd.exe" "E:\TO_MODIFY\files" "[0-9]{6,8}[/]?[0-9]*/[0-9]*/[0-9]{5,6}" "BACKUP"
echo Sample : %~nx0 "e:\Program Files (x86)\A-PDF Text Replace\ptrcmd.exe" "E:\TO_MODIFY\files" "E:\regex.txt" "BACKUP REGEX_FILE"
echo -------
echo CALL apdf_remove_text "!arg1!" "!arg2!" "!arg3!" "!arg4!"

call :apdf_remove_text "!arg1!" "!arg2!" "!arg3!" "!arg4!"

@goto :end


:apdf_remove_text
        @setlocal disableDelayedExpansion
	set "apdfexe_path=%~1"
	set "pdf_path=%~2"
	set "arg=%~3"
	set "opt=%~4"
        @setlocal enableDelayedExpansion
	set "backup="
	set "regex="
	set "regex_file="
	REM by default the arg is a regex
	set "_flag_regex=ON"
	set "_flag_file_regex="

	for %%O in (%opt%) do (
		if "%%O"=="BACKUP" (
			set "backup=.backup.pdf"
		)
		if "%%O"=="WORKSPACE" (
			set _opt_share_workspace=ON
		)
		if "%%O"=="REGEX" (
			set "_flag_regex=ON"
			set "_flag_file_regex="
		)
		if "%%O"=="REGEX_FILE" (
			set "_flag_regex="
			set "_flag_file_regex=ON"
		)
	)

	if "!_flag_file_regex!"=="ON" (
		set "regex="
		set "regex_file=!arg!"
		if exist "!regex_file!" (
			echo BEGIN loading regex file !regex_file!
			for /f "delims=" %%L in (!regex_file!) do (
				set "l=%%L"
				if not "!l:~0,2!"=="##" (
					echo Loading regex : %%L
					set "regex=!regex!(%%L)?"
				) else (
					echo Comment : %%L
				)
			)
			echo END loading regex file !regex_file!
		) else (
			echo File !regex_file! do not exist
			goto :end
		)
	) else (
		set "regex=!arg!"
		set "regex_file="
	)

	if not "!regex!"=="" (
		echo Will remove "!regex!"
		echo From "%~2"
		echo -------
		set "attr=%~a2"
		set "dirattr=!attr:~0,1!"

		if /I "!dirattr!"=="d" (
			cd /D "!pdf_path!"
			for /R %%p in ("*.pdf") do (
				echo Found file : %%p
				if not "!backup!"=="" (
					@copy /y "%%p" "%%p!backup!" >nul 2>&1
				)
				REM echo "!apdfexe_path!" "%%p" "%%p" "!regex!" "$EMPTY$" -EY -CY
				"!apdfexe_path!" "%%p" "%%p" "!regex!" "$EMPTY$" -EY -CY
			)
		) else (
			set "extension=%~x2"
			if "!extension!"==".pdf" (
				if not "!backup!"=="" (
					@copy /y "!pdf_path!" "!pdf_path!!backup!" >nul 2>&1
				)
				REM echo "!apdfexe_path!" "!pdf_path!" "!pdf_path!" "!regex!" "$EMPTY$" -EY -CY
				"!apdfexe_path!" "!pdf_path!" "!pdf_path!" "!regex!" "$EMPTY$" -EY -CY
			)
		)
	) else (
		echo Error : Empty regex
		goto :end	
	)
goto :eof



:end
@cd /D "%CURRENT_RUNNING_DIR%"
@echo on