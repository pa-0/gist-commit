:: -----------------------------------------------------------------------------------------
:: Cheat Command Wrapper Script
:: -----------------------------------------------------------------------------------------
:: This batch script acts as a wrapper for 'cheat.exe', enhancing its functionality
:: by allowing more intuitive command-line interactions. Specifically, it:
::
:: 1. Directly accesses cheatsheets or tags with a single argument.
:: 2. Facilitates search within a cheatsheet using multiple arguments, treating them
::    as a single search query.
:: 3. Dynamically resolves the paths to the community and personal cheatsheets
::    directories using the %APPDATA% variable, ensuring flexibility and user-specific
::    behavior.
:: 4. Checks for the existence of a cheatsheet before attempting to list or search,
::    thereby intelligently deciding between listing tags or displaying cheatsheet content.
::
:: Usage:
::    To view a cheatsheet:             script_name <cheatsheet_name>
::    To list cheatsheets by tag:       script_name <tag>
::    To search within a cheatsheet:    script_name <cheatsheet_name> <search_terms>
::
:: Note: Replace 'script_name' with the actual name of this batch file when using.
:: -----------------------------------------------------------------------------------------


@echo off
setlocal enabledelayedexpansion

:: Setup Section
:: Here, we define essential variables for the script's operation, including the path to 'cheat.exe'
:: and the directories where cheatsheets are stored. This setup is crucial for the dynamic functionality
:: of the script, allowing it to interact with the cheat system effectively.

set CHEAT_EXE_PATH=cheat.exe


:: Check for no arguments and provide usage instructions.
if "%~1"=="" (
	echo ----------------------------------------------------------------------------------------
    echo Usage instructions for this Cheat Wrapper Script:
    echo.
    echo - Direct call to a cheatsheet: c.bat ^<cheatsheet^>
    echo - List cheatsheets tagged with a term: c.bat ^<tag^>
    echo - Search within a cheatsheet: c.bat ^<cheatsheet^> ^<search_term^> [additional_terms...]
    echo.
	echo ----------------------------------------------------------------------------------------
	echo.
    echo Original cheat.exe operations:
    echo.
    "%CHEAT_EXE_PATH%"
    goto :eof
)


:: Utilizing the %APPDATA% environment variable ensures that the script dynamically adapts
:: to the user's application data directory, making the script more portable and user-specific.
set COMMUNITY_DIR=%APPDATA%\cheat\cheatsheets\community
set PERSONAL_DIR=%APPDATA%\cheat\cheatsheets\personal


:: Argument Handling Section
:: This part of the script checks how many arguments are provided by the user and branches the logic
:: accordingly. If only one argument is provided, it could either be a direct call to a cheatsheet or
:: an indication to list cheatsheets tagged with the specified term.

if "%~2"=="" (
    call :checkCheatsheetExistence %1
    if !EXISTENCE! equ 1 (
        "%CHEAT_EXE_PATH%" %1
    ) else (
        "%CHEAT_EXE_PATH%" -l -t %1
    )
    goto :eof
)


:: Search Term Processing Section
:: When the user provides more than one argument, this indicates an intent to search within a specific
:: cheatsheet. This section accumulates all additional arguments into a single search phrase,
:: ensuring that the search functionality of 'cheat.exe' is used effectively.

set "CHEATSHEET=%1"
shift
set "SEARCH_TERMS="

:moreargs
if "%~1"=="" goto :compilesearch
set "SEARCH_TERMS=!SEARCH_TERMS! %1"
shift
goto :moreargs


:: Command Execution Section
:: After processing the arguments, this section compiles the final command and executes it,
:: calling 'cheat.exe' with the appropriate parameters based on the user's input.

:compilesearch
														   
"%CHEAT_EXE_PATH%" !CHEATSHEET! -s "!SEARCH_TERMS!"
goto :eof


:: Cheatsheet Existence Check Subroutine
:: This subroutine is a utility function used to determine if a specified cheatsheet exists
:: within the known cheatsheet directories. It sets an 'EXISTENCE' flag based on the findings,
:: which influences the script's flow in the argument handling section.

:checkCheatsheetExistence
set EXISTENCE=0
if exist "%COMMUNITY_DIR%\%~1.*" set EXISTENCE=1
if exist "%PERSONAL_DIR%\%~1.*" set EXISTENCE=1
goto :eof
