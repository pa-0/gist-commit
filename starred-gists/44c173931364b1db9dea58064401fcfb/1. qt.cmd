@echo off

setlocal
setlocal enabledelayedexpansion

set R=%CD%

set EXPATVER=2.1.0
set DBUSVER=1.10.6
set ZLIBVER=1.2.8
set OSSLVER=1.0.2g
set CURLVER=7.47.1
set QTVER=5.6.0

rem set C=mingw32
rem set CMAKEGEN="MinGW Makefiles"
rem set MAKECMD=mingw32-make
rem set MAKECMDMP=%MAKECMD% -j8
rem set LIBPREFIX=lib
rem set LIBSUFFIX=.a
rem set QTOPTS=

set C=%TR_CONF%
set CMAKEGEN="NMake Makefiles"
set MAKECMD=nmake
set MAKECMDMP=%MAKECMD%
set LIBPREFIX=
set LIBSUFFIX=.lib
set PREFIX=%R%\3rd-party-%C%
set QTOPTS=-platform win32-msvc2015 -mp -ltcg -opensource -confirm-license
set CMAKEOPTS="-DCMAKE_SHARED_LINKER_FLAGS:STRING=/LTCG /INCREMENTAL:NO /OPT:REF" "-DCMAKE_EXE_LINKER_FLAGS:STRING=/LTCG /INCREMENTAL:NO /OPT:REF"
set EXPATOPTS=-DBUILD_tools=OFF -DBUILD_examples=OFF -DBUILD_tests=OFF -DBUILD_static=OFF
set DBUSOPTS_DBG=-DEXPAT_INCLUDE_DIR:PATH=%PREFIX%\include -DEXPAT_LIBRARY:FILEPATH=%PREFIX%\lib\%LIBPREFIX%expatd%LIBSUFFIX% -DDBUS_BUILD_TESTS=OFF
set DBUSOPTS_REL=-DEXPAT_INCLUDE_DIR:PATH=%PREFIX%\include -DEXPAT_LIBRARY:FILEPATH=%PREFIX%\lib\%LIBPREFIX%expat%LIBSUFFIX% -DDBUS_BUILD_TESTS=OFF
set OSSLOPTS=
set CURLOPTS=-DCMAKE_USE_OPENSSL=ON -DCURL_WINDOWS_SSPI=OFF -DBUILD_CURL_TESTS=OFF -DCURL_DISABLE_DICT=ON -DCURL_DISABLE_GOPHER=ON -DCURL_DISABLE_IMAP=ON -DCURL_DISABLE_SMTP=ON -DCURL_DISABLE_POP3=ON -DCURL_DISABLE_RTSP=ON -DCURL_DISABLE_TFTP=ON -DCURL_DISABLE_TELNET=ON -DCURL_DISABLE_LDAP=ON -DCURL_DISABLE_LDAPS=ON -DENABLE_MANUAL=OFF

md expat-%EXPATVER%\%C%-dbg
pushd expat-%EXPATVER%\%C%-dbg
cmake .. -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_DEBUG_POSTFIX=d %EXPATOPTS% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd
md expat-%EXPATVER%\%C%-rel
pushd expat-%EXPATVER%\%C%-rel
cmake .. -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=%PREFIX% %EXPATOPTS% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd

md dbus-%DBUSVER%\%C%-dbg
pushd dbus-%DBUSVER%\%C%-dbg
cmake ..\cmake -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_DEBUG_POSTFIX=d %DBUSOPTS_DBG% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd
md dbus-%DBUSVER%\%C%-rel
pushd dbus-%DBUSVER%\%C%-rel
cmake ..\cmake -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=%PREFIX% %DBUSOPTS_REL% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd

md zlib-%ZLIBVER%\%C%-dbg
pushd zlib-%ZLIBVER%\%C%-dbg
cmake .. -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd
md zlib-%ZLIBVER%\%C%-rel
pushd zlib-%ZLIBVER%\%C%-rel
cmake .. -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=%PREFIX% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd

if "%C%" == "msvc32" (
    set OSSLCFG=VC-WIN32
    set OSSLPREP=ms\do_nasm.bat
) else (
    set OSSLCFG=VC-WIN64A
    set OSSLPREP=ms\do_win64a.bat
)

xcopy /E /I /H /R /Y openssl-%OSSLVER% openssl-%OSSLVER%-%C%-dbg
if not !errorlevel! == 0 exit /b 1
pushd openssl-%OSSLVER%-%C%-dbg
patch -p1 -i %R%\openssl-1.0.2d-debug.patch
if not !errorlevel! == 0 exit /b 1
perl Configure --prefix=%PREFIX% debug-%OSSLCFG%
if not !errorlevel! == 0 exit /b 1
%COMSPEC% /c %OSSLPREP%
if not !errorlevel! == 0 exit /b 1
nmake -f ms\ntdll.mak
if not !errorlevel! == 0 exit /b 1
nmake -f ms\ntdll.mak install
if not !errorlevel! == 0 exit /b 1
popd
xcopy /E /I /H /R /Y openssl-%OSSLVER% openssl-%OSSLVER%-%C%-rel
if not !errorlevel! == 0 exit /b 1
pushd openssl-%OSSLVER%-%C%-rel
perl Configure --prefix=%PREFIX% %OSSLCFG%
if not !errorlevel! == 0 exit /b 1
%COMSPEC% /c %OSSLPREP%
if not !errorlevel! == 0 exit /b 1
nmake -f ms\ntdll.mak
if not !errorlevel! == 0 exit /b 1
nmake -f ms\ntdll.mak install
if not !errorlevel! == 0 exit /b 1
popd

md curl-%CURLVER%\%C%-dbg
pushd curl-%CURLVER%\%C%-dbg
cmake .. -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_DEBUG_POSTFIX=d %CURLOPTS% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd
md curl-%CURLVER%\%C%-rel
pushd curl-%CURLVER%\%C%-rel
cmake .. -G %CMAKEGEN% -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=%PREFIX% %CURLOPTS% %CMAKEOPTS%
if not !errorlevel! == 0 exit /b 1
%MAKECMDMP%
if not !errorlevel! == 0 exit /b 1
%MAKECMD% install/fast
if not !errorlevel! == 0 exit /b 1
popd

if not %QTVER% geq 5.0.0 (
    md %QTVER%-%C%
    xcopy /Y /I /E %QTVER%-src\mkspecs %QTVER%-%C%\mkspecs
)

set PATH=%PREFIX%\bin;%PATH%
set PATH_SAVE=%PATH%

if %QTVER% geq 5.0.0 (
    set QTOPTS=%QTOPTS% -prefix %R%\%QTVER%-%C% -force-debug-info ^
	-no-opengl ^
	-dbus ^
	-skip connectivity ^
	-skip declarative ^
	-skip doc ^
	-skip enginio ^
	-skip graphicaleffects ^
	-skip location ^
	-skip multimedia ^
	-skip quickcontrols ^
	-skip script ^
	-skip sensors ^
	-skip serialport ^
	-skip webchannel ^
	-skip webengine ^
	-skip websockets ^
	-ssl ^
	-openssl ^
	-system-zlib ^
	-qt-pcre ^
	-qt-libpng ^
	-qt-libjpeg ^
	-no-harfbuzz ^
	-no-sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2 ^
	-no-wmf-backend ^
	-no-qml-debug ^
	-nomake examples %QTOPTS% -I %PREFIX%\include -L %PREFIX%\lib

    rem Up to 5.5.x:
    rem	-skip quick1 ^
    rem	-skip webkit ^
    rem	-skip webkit-examples ^


    set PATH=%R%\%QTVER%-%C%-build-dbg\qtbase\lib;%PATH_SAVE:)=^)%

    md %QTVER%-%C%-build-dbg
    pushd %QTVER%-%C%-build-dbg
    %COMSPEC% /c %R%\%QTVER%-src\configure.bat !QTOPTS! -debug OPENSSL_LIBS="libeay32d.lib ssleay32d.lib" ZLIB_LIBS="zlibd.lib"
    if not !errorlevel! == 0 exit /b 1
    %MAKECMDMP%
    if not !errorlevel! == 0 exit /b 1
    %MAKECMD% install
    if not !errorlevel! == 0 exit /b 1
    popd

    set PATH=%R%\%QTVER%-%C%-build-rel\qtbase\lib;%PATH_SAVE:)=^)%

    md %QTVER%-%C%-build-rel
    pushd %QTVER%-%C%-build-rel
    %COMSPEC% /c %R%\%QTVER%-src\configure.bat !QTOPTS! -release OPENSSL_LIBS="libeay32.lib ssleay32.lib" ZLIB_LIBS="zlib.lib"
    if not !errorlevel! == 0 exit /b 1
    %MAKECMDMP%
    if not !errorlevel! == 0 exit /b 1
    %MAKECMD% install
    if not !errorlevel! == 0 exit /b 1
    popd

    set PATH=%PATH_SAVE:)=^)%
) else (
    %R%\%QTVER%-src\configure.exe -prefix %R%\%QTVER%-%C% -debug-and-release -fast ^
        -no-qt3support ^
        -no-opengl ^
        -dbus ^
        -qt-zlib ^
        -no-phonon ^
        -no-phonon-backend ^
        -no-multimedia ^
        -no-audio-backend ^
        -no-webkit ^
        -no-script ^
        -no-scripttools ^
        -no-declarative ^
        -no-declarative-debug ^
        -nomake examples -nomake demos %QTOPTS% -I %R%\dbus-%DBUSVER% -I %R%\dbus-%DBUSVER%\%C% -L %R%\dbus-%DBUSVER%\%C%\bin
    if not !errorlevel! == 0 exit /b 1
    %MAKECMDMP%
    if not !errorlevel! == 0 exit /b 1
    %MAKECMD% install
    if not !errorlevel! == 0 exit /b 1
)
