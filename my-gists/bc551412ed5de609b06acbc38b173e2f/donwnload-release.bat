@echo off
if "%~1"=="" goto :USAGE

where /q curl.exe || (
    echo Error: curl command not found.
    exit /b 1
)

setlocal enabledelayedexpansion

:PARSE
set "_args=%~1"
if "%~1"=="" (
    goto :BEGIN
) else if "!_args:~0,1!"=="/" (
    if "!_args!"=="/?" (
        endlocal && goto :USAGE
    ) else if "!_args!"=="/o" (
        set "out_file=%~f2"
    ) else if "!_args!"=="/p" (
        set "pattern_name=%~2"
    ) else if "!_args!"=="/m" (
        echo.%~2| findstr "^[-][1-9][0-9]*$ ^[1-9][0-9]*$ ^0$" >nul || (
            echo Option %1: requires a numeric value.
            endlocal && exit /b 1
        )
        set "max_depth=%~2"
    ) else if "!_args!"=="/t" (
        set "tag_name=%~2"
    ) else (
        echo Unknown option: %1
        echo Try '%0 /?'
        endlocal && exit /b 1
    )
    if "%~2"=="" (
        echo Option %1: requires a value.
        endlocal && exit /b 1
    )
    shift /1
) else (
    set "owner_repo=%~1"
)
shift /1
goto :PARSE

:USAGE
echo.Usage: %0 [options] ^<owner/repo^>
echo.
echo.  owner  Repository account owner.
echo.  repo   Repository name ^(without .git^).
echo.
echo.Options:
echo.  /t     Release tag name; defaults to latest.
echo.  /p     File name pattern; defaults to all releases.
echo.  /o     Output file; defaults to all releases.
echo.  /m     Maximum download depth; defaults to 256.
echo.
echo.Notes:
echo.  - Parameters are case-insensitive.
echo.  - Curl should be installed, You can download it from https://curl.se/windows/.
exit /b 0

:BEGIN
if not defined owner_repo (
    echo Hostname is required: {owner}/{repo}.
    echo Try '%0 /?'
    endlocal && exit /b 1
)
for /f "tokens=1-2 delims=/" %%i in ("!owner_repo!") do (
    if "%%~i"=="" (
        echo Owner name is required.
        endlocal && exit /b 1
    )
    if "%%~j"=="" (
        echo Repository name is required.
        endlocal && exit /b 1
    )
    set "owner_name=%%~i"
    set "repo_name=%%~j"
)

if defined tag_name (
    set "tag_name=tags/%tag_name%"
) else (
    set "tag_name=latest"
)

set GH_API=https://api.github.com/repos/%owner_name%/%repo_name%/releases/%tag_name%

set count=0
if defined out_file set max_depth=0
if not defined max_depth set max_depth=256

for /f "tokens=2" %%i in ('
    curl.exe -Ls -H "Accept: application/vnd.github+json" "%GH_API%" ^|^
    findstr /i "browser_download_url.*%pattern_name%"
') do if not "%%~i"=="" (
    set "download_url=%%~i"
    set "file_name=%%~nxi"
    if defined out_file (
        call :downloadFile "%out_file%" "!download_url!"
    ) else (
        call :downloadFile "!file_name!" "!download_url!"
    )
    if !max_depth! equ !count! goto :ENDED
    set /a count+=1
) else (
    set errorlevel=!errorlevel!
)

:ENDED
endlocal & (
    exit /b %errorlevel%
)

:downloadFile
set /p x="Downloading '%~2'..." <nul
curl.exe -Lso "%~f1" --create-dirs "%~2"
if %errorlevel% neq 0 (
    echo. error^(%errorlevel%^).
) else (
    echo. done^(%errorlevel%^).
)
exit /b %errorlevel%
