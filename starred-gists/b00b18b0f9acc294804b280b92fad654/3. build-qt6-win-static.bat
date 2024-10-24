@echo off
setlocal
setlocal enabledelayedexpansion
cls

set BEGINTIME=%TIME%

echo [1;93m**********************************************************************[0m
echo [1;93m***********    QT Static Windows Build Script   **********************[0m
echo [1;93m**********************************************************************[0m

rem buildqt_6_4_static.bat --download --qt-version=6.4 --qt-subversion=6.4.0 --devtools-path="C:\dev-tools" --erase-archive --source-root="D:\SDKs\Qt\6.4.0-static\src" --build-root="D:\SDKs\Qt\6.4.0-static" --vs-version=2019

set ORIG_FOLDER=%~dp0

SET CMD=%~1

IF "%CMD%" == "" (
  call :SHOWUSAGE
  EXIT /B 1
)

echo [1;93m**********************************************************************[0m
echo [1;33Starting build 	%DATE% %TIME%[0m
echo [1;93m**********************************************************************[0m

SET PARAM_DOWNLOAD=0
SET PARAM_ERASE_ARCHIVE=0
SET PARAM_ERASE_PCH=0
SET PARAM_QT_VERSION=
SET PARAM_QT_SUBVERSION=
SET PARAM_DEV_TOOLS=
SET PARAM_SOURCE_ROOT=
SET PARAM_BUILD_ROOT=
SET PARAM_VSVERSION=2019

SET DELIM =--


:args
SET PARAM=%~1
SET ARG=%~2
call :startsWith %PARAM% %DELIM%
rem ECHO %errorlevel%

rem if %errorlevel% neq 1 (
rem   ECHO %PARAM%=
rem   shift	
rem   goto :args
rem )

rem ECHO %PARAM%=%ARG%
IF "%PARAM%" == "--qt-version" (
  IF NOT "%ARG%" == "" (
    SET PARAM_QT_VERSION=%ARG%
	SHIFT
	SHIFT
  ) ELSE (
    ECHO [31mError : Missing [31m--qt-version[0m parameter value. 1>&2
    call :SHOWUSAGE
    EXIT /B 1
  )
) ELSE IF "%PARAM%" == "--qt-subversion" (
  IF NOT "%ARG%" == "" (
    SET PARAM_QT_SUBVERSION=%ARG%
	SHIFT
	SHIFT
  ) ELSE (
    ECHO [31mError : Missing [31m--qt-subversion[0m parameter value. 1>&2
    call :SHOWUSAGE
    EXIT /B 1
  )  
) ELSE IF "%PARAM%" == "--devtools-path" (
  IF NOT "%ARG%" == "" (
    SET PARAM_DEV_TOOLS=%ARG%
	SHIFT
	SHIFT
  ) ELSE (
    ECHO [31mError : Missing [31m--devtools-path[0m parameter value. 1>&2
    call :SHOWUSAGE
    EXIT /B 1
  )   
) ELSE IF "%PARAM%" == "--source-root" (
  IF NOT "%ARG%" == "" (
    SET PARAM_SOURCE_ROOT=%ARG%
	SHIFT
	SHIFT
  ) ELSE (
    ECHO [31mError : Missing [31m--source-root[0m parameter value. 1>&2
    call :SHOWUSAGE
    EXIT /B 1
  )  
) ELSE IF "%PARAM%" == "--build-root" (
  IF NOT "%ARG%" == "" (
    SET PARAM_BUILD_ROOT=%ARG%
	SHIFT
	SHIFT
  ) ELSE (
    ECHO [31mError : Missing [31m--build-root[0m parameter value. 1>&2
    call :SHOWUSAGE
    EXIT /B 1
  )    
) ELSE IF "%PARAM%" == "--vs-version" (
  IF NOT "%ARG%" == "" (
    SET PARAM_VSVERSION=%ARG%
	SHIFT
	SHIFT
  ) ELSE (
    ECHO [31mError : Missing [31m--vs-version[0m parameter value. 1>&2
    call :SHOWUSAGE
    EXIT /B 1
  )   
) ELSE IF "%PARAM%" == "--download" (
  SET PARAM_DOWNLOAD=1
  SHIFT
) ELSE IF "%PARAM%" == "--erase-archive" (
  SET PARAM_ERASE_ARCHIVE=1
  SHIFT
) ELSE IF "%PARAM%" == "--erase-pch" (
  SET PARAM_ERASE_PCH=1
  SHIFT  
) ELSE IF "%PARAM%" == "" (
  GOTO endargs 
) ELSE (
  ECHO Unrecognized option %1. 1>&2
  call :SHOWUSAGE
  EXIT /B 1
)

GOTO args
:endargs

rem check input parameters
if [%PARAM_QT_VERSION%]==[] (
  ECHO [31mError : Missing --qt-version parameter. Build aborted.[0m
  call :SHOWUSAGE
  EXIT /B 1
)

if [%PARAM_QT_SUBVERSION%]==[] (
  ECHO [31mError : Missing --qt-subversion parameter. Build aborted.[0m
  call :SHOWUSAGE
  EXIT /B 1
)

if [%PARAM_DEV_TOOLS%]==[] (
  ECHO [31mError : Missing --devtools-path parameter. Build aborted.[0m
  call :SHOWUSAGE
  EXIT /B 1
)

if [%PARAM_SOURCE_ROOT%]==[] (
  ECHO [31mError : Missing --source-root parameter. Build aborted.[0m
  call :SHOWUSAGE
  EXIT /B 1
)
if [%PARAM_BUILD_ROOT%]==[] (
  ECHO [31mError : Missing --build-root parameter. Build aborted.[0m
  call :SHOWUSAGE
  EXIT /B 1
)


if %PARAM_VSVERSION% LSS 2019 ( echo [31mError : Visual Studio version should be at least 2019. Build Aborted.[0m
 EXIT /B 1
 )

set VS_VERSION=16.0
set VS_VERSION_SEARCH_MIN=16
set VS_VERSION_SEARCH_MAX=17
set VS_VERSION_STRING=MS Visual Studio %PARAM_VSVERSION%


if %PARAM_VSVERSION% == 2022 ( 
 set VS_VERSION=17.0
 set VS_VERSION_SEARCH_MIN=17
 set VS_VERSION_SEARCH_MAX=18
 set VS_VERSION_STRING%=MS Visual Studio 2022
 )
 
echo [1;33mLocating MSBUILD  [ version %VS_VERSION% ] folder...[0m

for /f "usebackq tokens=*" %%i in (`vswhere -version [%VS_VERSION_SEARCH_MIN%^,%VS_VERSION_SEARCH_MAX%^) -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
set MSBUILD_DIR=%%i
)

if "%MSBUILD_DIR%"=="" ( echo [31mError : Cannot locate MSBUILD [ version %VS_VERSION% ]. Build Aborted.[0m
  EXIT /B 1
)

echo MSBUILD [ version %VS_VERSION% ] located at [1;96m%MSBUILD_DIR%[0m

set VC_BAT_PATH=%MSBUILD_DIR%\VC\Auxiliary\Build\vcvarsall.bat


if not exist "%VC_BAT_PATH%" (
	echo [31mError : Cannot locate vcvarsall.bat file [ version %VS_VERSION% ]. Build Aborted.[0m
		EXIT /B 1)

echo vcvarsall.bat [ version %VS_VERSION% ] located at [1;96m%VC_BAT_PATH%[0m
echo.
echo [1;33mSetting build environment...[0m
CALL "%VC_BAT_PATH%" amd64 || EXIT /B

echo.
echo [1;33mChecking and cleaning build folders[0m

rem prepare folders


SET "QT_VERSION=%PARAM_QT_VERSION%"
SET "QT_SUBVERSION=%PARAM_QT_SUBVERSION%"
SET "QT_SOURCES_ROOT_FOLDER=%PARAM_SOURCE_ROOT%"
SET "QT_SOURCES_DOWNLOAD_FOLDER=%PARAM_SOURCE_ROOT%\download"
SET "QT_SOURCES_FOLDER=%QT_SOURCES_ROOT_FOLDER%\qt-everywhere-src-%QT_SUBVERSION%"
SET "QT_BUILD_FOLDER=%PARAM_BUILD_ROOT%\build"
SET "QT_INSTALL_FOLDER=%PARAM_BUILD_ROOT%\msvc%PARAM_VSVERSION%_64"
SET "QT_DEV_TOOLS=%PARAM_DEV_TOOLS%"

rem %QT_INSTALL_ROOT% - Build and install folders based on 
rem %QT_SOURCE_ROOT% - download and unpack sources folder
rem %QT_BUILD_FOLDER% - build folder

rem build download string
SET QT_DOWNLOAD_URL=https://download.qt.io/archive/qt/%QT_VERSION%/%QT_SUBVERSION%/single/qt-everywhere-src-%QT_SUBVERSION%.zip
SET QT_DOWNLOAD_FILE=%QT_SOURCES_ROOT_FOLDER%\qt-everywhere-src-%QT_SUBVERSION%.zip

echo:
echo:
echo [1;33mProcess Parameters :[0m
echo	Current folder : 		[1;96m%ORIG_FOLDER%[0m
echo	QT Version : 			[1;96m%QT_VERSION%[0m
echo	QT Subversion : 		[1;96m%QT_SUBVERSION%[0m
echo	QT Sources Download Folder : 	[1;96m%QT_SOURCES_DOWNLOAD_FOLDER%[0m
echo	QT Sources Folder : 		[1;96m%QT_SOURCES_FOLDER%[0m
echo	QT Build Folder : 		[1;96m%QT_BUILD_FOLDER%[0m
echo	Qt Install folder : 		[1;96m%QT_INSTALL_FOLDER%[0m
echo	Dev Tools folder : 		[1;96m%QT_DEV_TOOLS%[0m
if %PARAM_DOWNLOAD%==1 (echo	Download sources ? 		[1;96mYES[0m ) else (echo		Download sources ? 		[1;96mNO[0m )
if %PARAM_DOWNLOAD%==1 (echo	Qt sources download URL :	[1;96m%QT_DOWNLOAD_URL%[0m )
if %PARAM_DOWNLOAD%==1 (echo	Qt sources download file :	[1;96m%QT_DOWNLOAD_FILE%[0m )

if %PARAM_ERASE_ARCHIVE%==1 (echo	Delete sources after unpack ?	[1;96mYES[0m ) else (echo		Delete sources adter unpack ?	[1;96mNO[0m )
if %PARAM_ERASE_PCH%==1 (echo	Delete *.pch files after build ?	[1;96mYES[0m ) else (echo		Delete *.pch files after build ?	[1;96mNO[0m )
echo	VS Version : 			[1;96m%VS_VERSION_STRING% [ compiler version : %VS_VERSION% ] [0m
echo:


rem checking the dev tools prerequisites

if not exist "%QT_DEV_TOOLS%%\ninja\ninja.exe" ( 
 echo [43mWarning : ninja.exe has not been found at %QT_DEV_TOOLS%%\ninja folder. Check if ninja executable path listed in PATH[0m
)

if not exist "%QT_DEV_TOOLS%\openssl\lib\libcrypto.lib" ( 
 echo [31mError : Cannot locate openssl libcrypto.lib library at  at %QT_DEV_TOOLS%%\openssl\lib folder. Build Aborted.[0m&exit /B 1
)

if not exist "%QT_DEV_TOOLS%\openssl\lib\libssl.lib" ( 
 echo [31mError : Cannot locate openssl libssl.lib library at  at %QT_DEV_TOOLS%%\openssl\lib folder. Build Aborted.[0m&exit /B 1
)

rem for sources we need 5368709120 bytes
rem for build we need 139586437120 bytes
rem total we need 144955146240 bytes
rem checking available space 

echo [1;33mChecking available disk space...[0m
SET SAME_DISK=1
if %QT_SOURCES_FOLDER:~0,2% NEQ %QT_BUILD_FOLDER:~0,2% SET SAME_DISK=0

if %SAME_DISK%==1 (
wmic LogicalDisk where "DeviceID='%QT_SOURCES_FOLDER:~0,2%' and FreeSpace > 144955146240" get DeviceID 2>&1 ^
 | find /i "%QT_SOURCES_FOLDER:~0,2%" >nul || (echo [31mError : Not enough free space for sources. Required at least 140 GB free on disk %QT_SOURCES_FOLDER:~0,2%. Build Aborted.[0m&exit /B 1)
) else (
  wmic LogicalDisk where "DeviceID='%QT_SOURCES_FOLDER:~0,2%' and FreeSpace > 5368709120" get DeviceID 2>&1 ^
   | find /i "%QT_SOURCES_FOLDER:~0,2%" >nul || (echo [31mError : Not enough free space for sources. Required at least 5 GB free on disk %QT_SOURCES_FOLDER:~0,2%. Build Aborted.[0m&exit /B 1)
  wmic LogicalDisk where "DeviceID='%QT_BUILD_FOLDER:~0,2%' and FreeSpace > 5368709120" get DeviceID 2>&1 ^
   | find /i "%QT_BUILD_FOLDER:~0,2%" >nul || (echo [31mError : Not enough free space for sources. Required at least 130 GB free on disk %QT_BUILD_FOLDER:~0,2%. Build Aborted.[0m&exit /B 1)
 )
 
echo [33mEnough disk space detected.[0m 

rem ---------------------------------------------------------------------------
rem Preparing build folder
rem ---------------------------------------------------------------------------

if not exist "%QT_BUILD_FOLDER%\" ( 
  echo Build Path [1;96m%QT_BUILD_FOLDER%[0m does not exist. Creating... 
  md %QT_BUILD_FOLDER% || exit /B 1
) else (
 echo Build Path [1;96m%QT_BUILD_FOLDER%[0m exists. Cleaning up build folder...
 cd %QT_BUILD_FOLDER%
 for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q ) || exit /B 1
 echo Build Path [1;96m%QT_BUILD_FOLDER%[0m has been cleaned up.
 echo:
)

cd %ORIG_FOLDER%

rem ---------------------------------------------------------------------------
rem Preparing source folder
rem ---------------------------------------------------------------------------

if %PARAM_DOWNLOAD%==0 goto :ignore_download


if %PARAM_DOWNLOAD% == 1 (
rem check if source folder root exists
  if not exist "%QT_SOURCES_ROOT_FOLDER%\" ( 
    mkdir "%QT_SOURCES_ROOT_FOLDER%"
  ) else (
    if not exist "%QT_SOURCES_DOWNLOAD_FOLDER%\" ( 
	   echo The download path [1;96m%QT_SOURCES_ROOT_FOLDER%[0m is ready  
	) else (
	  echo For downloading sources the download path [1;96m%QT_SOURCES_DOWNLOAD_FOLDER%[0m have to be cleaned. Cleaning download path...
	  cd %QT_SOURCES_ROOT_FOLDER%
	  for /F "delims=" %%i in ('dir /b') do (
		echo [33mDeleting '%%i'...[0m
	    rmdir "%%i" /s/q || del "%%i" /s/q )  || exit /B 1 
		echo The download path [1;96m%QT_SOURCES_ROOT_FOLDER%[0m is ready.
	  )
	)
  )
) 

cd %ORIG_FOLDER%
echo [1;96mUpdating python modules needed for download and unpacking...[0m
call python.exe -m pip install --upgrade pip
call python install_modules.py

echo [33m [0m
echo [33mPython modules has been updated. Start downloading ...[0m
echo:

set STARTTIME=%TIME%
set ERRORLEVEL=
echo Calling download and extract script "python download.py %PARAM_QT_VERSION% %PARAM_QT_SUBVERSION% %QT_SOURCES_ROOT_FOLDER%"
call python download.py %PARAM_QT_VERSION% %PARAM_QT_SUBVERSION% %QT_SOURCES_ROOT_FOLDER%
if !ERRORLEVEL! NEQ 0 (
	echo [31mError : Cannot Download source archive or unzip it. Build Aborted.[0m
	EXIT /B 1 )
)

set ENDTIME=%TIME% 
call :elapsed_time %STARTTIME% %ENDTIME% DURATION
echo [1;96mThe Qt sources have been downloaded and extracted sucessfully. [Duration = %DURATION%]. Starting configuration script...[0m


if [%PARAM_ERASE_ARCHIVE%]==[] goto :start_configure
if %PARAM_ERASE_ARCHIVE% == 1 ( 
  if exist %QT_SOURCES_DOWNLOAD_FOLDER% rmdir %QT_SOURCES_DOWNLOAD_FOLDER% /s/q
)
goto :start_configure


:ignore_download
echo:
rem check if sources exist
echo No source download requested, assuming the sources are already at %QT_SOURCES_FOLDER%
if not exist "%QT_SOURCES_FOLDER%\" ( 
  echo [31mError : Source folder does not exist. Build Aborted.[0m
  exit /B 1
)

For /F %%A in ('dir /b /a %QT_SOURCES_FOLDER%') Do (
    goto :src_not_empty
)
echo [31mError : Source folder is empty. Build Aborted.[0m
exit /B 1
  
:src_not_empty
echo  [1;96mThe source folder %QT_SOURCES_ROOT_FOLDER% is OK.[0m

:start_configure
echo [1;96mStarting build configure script...[0m

rem configure path

SET _ROOT=%QT_SOURCES_FOLDER%
SET PATH=%_ROOT%\qtbase\bin;%PATH%
SET PATH=%QT_DEV_TOOLS%\openssl;%PATH%
SET PATH=%QT_DEV_TOOLS%\ninja;%PATH%
SET PATH=%QT_DEV_TOOLS%\openssl\include;%PATH%
SET PATH=%QT_DEV_TOOLS%\openssl\lib;%PATH%
rem SET PATH=%QT_DEV_TOOLS%\perl;%PATH%
rem SET PATH=%QT_DEV_TOOLS%\perl\bin;%PATH%
SET PATH=%LLVM_INSTALL_DIR%;%PATH%
SET PATH=%LLVM_INSTALL_DIR%\bin;%PATH%
SET _ROOT=


set QT_SOURCES_FOLDER_SLASH=%QT_SOURCES_FOLDER:\=/%
set QT_INSTALL_FOLDER_SLASH=%QT_INSTALL_FOLDER:\=/%
set QT_DEV_TOOLS_SLASH=%QT_DEV_TOOLS:\=/%

echo Configure Dev Tools folder  	[1;33m%QT_DEV_TOOLS_SLASH%[0m
echo Configure Sources folder  	[1;33m%QT_SOURCES_FOLDER_SLASH%[0m
echo Configure Install folder  	[1;33m%QT_INSTALL_FOLDER_SLASH%[0m
echo Configure Build folder 		[1;33m%QT_BUILD_FOLDER%[0m

set OPENSSL_USE_STATIC_LIBS=ON
set "OPENSSL_ROOT_DIR=%QT_DEV_TOOLS_SLASH%/openssl"
set OPENSSL_MSVC_STATIC_RT=ON
set CMAKE_USE_OPENSSL=ON
set "CMAKE_PREFIX_PATH=%QT_DEV_TOOLS_SLASH%"
set CL=/MP
set LLVM_INSTALL_DIR="c:/LLVM"

echo [1;96mCalling a configuration script at "%QT_SOURCES_FOLDER%\configure.bat"[93m

cd %QT_BUILD_FOLDER%

set STARTTIME=%TIME% 
echo [1;93m**********************************************************************[0m
echo [1;93mConfigure start time	%DATE% %TIME%[0m
echo [1;93m**********************************************************************[0m


call %QT_SOURCES_FOLDER%/configure.bat ^
	-prefix %QT_INSTALL_FOLDER% ^
	-platform win32-msvc ^
	-debug-and-release ^
	-optimize-size ^
	-force-debug-info ^
	-static-runtime ^
	-static ^
	-DQT_NO_EXCEPTIONS=0 ^
	-c++std c++17 ^
	-opensource ^
	-opengl desktop ^
	-confirm-license ^
	-qt-zlib ^
	-qt-libjpeg ^
	-qt-libpng ^
	-qt-freetype ^
	-qt-tiff ^
	-qt-webp ^
	-qt-pcre ^
	-sql-sqlite ^
	-sql-odbc ^
	-qt-sqlite ^
	-no-sql-psql ^
	-ssl ^
	-openssl ^
	-openssl-linked ^
	-DFEATURE_clangcpp=ON ^
	-DOPENSSL_USE_STATIC_LIBS=ON ^
	-DOPENSSL_ROOT_DIR="%QT_DEV_TOOLS_SLASH%/openssl" ^
	-DOPENSSL_MSVC_STATIC_RT=ON ^
	-DCMAKE_USE_OPENSSL=ON ^
	-DBUILD_TESTING=OFF ^
	-DCMAKE_PREFIX_PATH="%QT_DEV_TOOLS_SLASH%/openssl/lib" ^
	-DCMAKE_INCLUDE_PATH="%QT_DEV_TOOLS_SLASH%/openssl/include" ^
	-DCMAKE_LIBRARY_PATH="%QT_DEV_TOOLS_SLASH%/openssl/lib" ^
	-nomake tests ^
	-nomake examples ^
	-no-feature-accessibility ^
	-no-feature-appstore-compliant ^
	-no-feature-gssapi ^
	-no-feature-itemmodeltester ^
	-no-feature-testlib_selfcover ^
	-no-feature-tuiotouch ^
	-no-feature-valgrind ^
	-no-feature-lcdnumber ^ 
	-no-harfbuzz ^
	-skip qt3d ^
	-skip qtactiveqt ^
	-skip qtcanvas3d ^
	-skip qtconnectivity ^
	-skip qtdoc ^
	-skip qtcoap ^
	-skip qtdatavis3d ^
	-skip qtgamepad ^
	-skip qtlottie ^
	-skip qtlocation ^
	-skip qtmqtt ^
	-skip qtopcua ^
	-skip qtserialbus ^
	-skip qtserialport ^
	-skip qtpositioning ^
	-skip qtpurchasing ^
	-skip qtquickcontrols ^
	-skip qtquickcontrols2 ^
	-skip qtquicktimeline ^
	-skip qtquick3d ^
	-skip qtremoteobjects ^
	-skip qtvirtualkeyboard ^
	-skip qtscxml ^
	-skip qtsensors ^
	-skip qtwayland ^
	-skip qtpositioning ^
	-skip qtwebchannel ^
	-skip qtwebengine ^
	-skip qtconnectivity ^
	-skip qtwebview
	
	

set ENDTIME=%TIME% 
call :elapsed_time %STARTTIME% %ENDTIME% DURATION
echo ****  Configuration done in [ %DURATION% ] *******************[0m



set STARTTIME=%TIME%
echo:
echo [1;96mStarting build...[0m
cd %QT_BUILD_FOLDER%
cmake --build . --parallel
echo [1;96m******   Build complete   *****[0m
echo :
echo [1;96mInstalling build...[0m
ninja install

set ENDTIME=%TIME%
call :elapsed_time %STARTTIME% %ENDTIME% DURATION

echo  [1;93mBuild and installation complete in [%DURATION%] *******************[0m

if [%PARAM_ERASE_ARCHIVE%]==[] goto :end
cd %QT_BUILD_FOLDER%

del /S *.pch
echo Build Path [1;96mAll PCH files in folder %QT_BUILD_FOLDER%[0m have been deleted.

:end
call :elapsed_time %BEGINTIME% %ENDTIME% DURATION

echo [1;93mTotal Build time : %DURATION%[0m
echo [1;93m**********************************************************************[0m
echo [1;93m***********    QT Static Windows Build COMPLETE **********************[0m
echo [1;93m**********************************************************************[0m




rem findstr /m "computerhope" hope.txt
rem if %errorlevel%==0 (
rem echo There is hope!
rem check if opnssl libraries are configured correctly
rem d:\SDKs\Qt\6.4.0-static\build\CMakeFiles\impl-Debug.ninja 
rem \dev-tools\openssl\lib\libcrypto.lib

cd %ORIG_FOLDER%



:NORMALIZEPATH
	SET RETVAL=%~dpfn1
	EXIT /B

:SHOWUSAGE
echo:
echo ------------------------------------------------------------------------------------------------------------------------
echo [1mUsage :    %~n0%~x0 
echo 		--qt-version=[Qt Major Version; ex : 6.4] 	: required
echo 		--qt-subversion=[Qt Subversion; ex : 6.4.0] 	: required
echo			--devtools-path=[Path to development tools]	: required
echo			--download						: optional [download sources from Qt repository]
echo			--erase-archive					: optional [erase source archive after unpacking]
echo			--erase-pch						: optional [erase all PCH files after build]
echo			--source-root[Path to sources root]		: required
echo			--build-root=[Path to build root]		: required
echo			--vs-version=[MS VIsual Studio Version]	: optional; default 2019
echo:
echo Example :  %~n0%~x0 --qt-version=6.4 --qt-subversion=6.4.0 --devtools-path="C:\dev-tools" --download --erase-archive --source-root="C:\Qt\src" --build-root="c:\Qt\6.4.0-static" --vs-version=2019[0m
EXIT /B 1

:time_to_centiseconds
:: %~1 - time
:: %~2 - centiseconds output variable
setlocal
set _time=%~1
for /F "tokens=1-4 delims=:.," %%a in ("%_time%") do (
   set /A "_result=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
endlocal & set %~2=%_result%
goto :eof

:centiseconds_to_time
:: %~1 - centiseconds
:: %~2 - time output variable
setlocal
set _centiseconds=%~1
rem now break the centiseconds down to hors, minutes, seconds and the remaining centiseconds
set /A _h=%_centiseconds% / 360000
set /A _m=(%_centiseconds% - %_h%*360000) / 6000
set /A _s=(%_centiseconds% - %_h%*360000 - %_m%*6000) / 100
set /A _hs=(%_centiseconds% - %_h%*360000 - %_m%*6000 - %_s%*100)
rem some formatting
if %_h% LSS 10 set _h=0%_h%
if %_m% LSS 10 set _m=0%_m%
if %_s% LSS 10 set _s=0%_s%
if %_hs% LSS 10 set _hs=0%_hs%
set _result=%_h%:%_m%:%_s%.%_hs%
endlocal & set %~2=%_result%
goto :eof

:elapsed_time
:: %~1 - time1 - start time
:: %~2 - time2 - end time
:: %~3 - elapsed time output
setlocal
set _time1=%~1
set _time2=%~2
call :time_to_centiseconds %_time1% _centi1
call :time_to_centiseconds %_time2% _centi2
set /A _duration=%_centi2%-%_centi1%
call :centiseconds_to_time %_duration% _result
endlocal & set %~3=%_result%
goto :eof


:startsWith [%1 - string to be checked;%2 - string for checking ] 
@echo off
rem :: sets errorlevel to 1 if %1 starts with %2 else sets errorlevel to 0

setlocal EnableDelayedExpansion

set "string=%~1"
set "checker=%~2"
rem set "var=!string:%~2=&echo.!"
set LF=^


rem ** Two empty lines are required
rem echo off
for %%L in ("!LF!") DO (
 	for /f "delims=" %%R in ("!checker!") do ( 
 		rem set "var=!string:%%~R%%~R=%%~L!"
 		set "var=!string:%%~R=#%%L!"
 	)
)
for /f "delims=" %%P in (""!var!"") DO (
	if "%%~P" EQU "#" (
		endlocal & exit /b 1
	) else (
		endlocal & exit /b 0
	)
)
