#!/usr/bin/env bash

mkdir -p build

MINGW="/usr/i686-w64-mingw32"
INCPATH="$MINGW/usr/include"
PLUGPATH="$MINGW/usr/plugins"
export CC="i686-w64-mingw32-gcc" CXX="i686-w64-mingw32-g++"
export PKG_CONFIG="/usr/bin/i686-w64-mingw32-pkg-config"
export PKG_CONFIG_PATH="$MINGW/usr/lib/pkgconfig:$MINGW/usr/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$MINGW/usr/lib/pkgconfig:$MINGW/usr/lib/pkgconfig"

CGO_CFLAGS="-Wno-unused-parameter -Wno-unused-variable" \
CGO_CXXFLAGS="-I$INCPATH -I$INCPATH/QtCore -I$INCPATH/QtGui -I$INCPATH/QtWidgets  -I$INCPATH/QtUiTools -Wno-unused-parameter -Wno-unused-variable" \
CGO_CXXFLAGS="$CGO_CXXFLAGS -pipe -O2 -std=gnu++11 -Wall -W -D_REENTRANT -DQT_NO_DEBUG -DQT_CORE_LIB -DQT_GUI_LIB -DQT_WIDGETS_LIB -DQT_UITOOLS_LIB -fPIC" \
CGO_LDFLAGS="-L$MINGW/usr/lib -L$MINGW/lib -L$PLUGPATH/platforms -L$PLUGPATH/generic" \
CGO_LDFLAGS="$CGO_LDFLAGS -lQt5Core -lz -lpcre16 -ldouble-conversion -lole32 -luuid -lws2_32 -ladvapi32 -lshell32 -luser32 -lkernel32 -lmpr" \
CGO_LDFLAGS="$CGO_LDFLAGS -ljpeg -lQt5Widgets -lQt5Gui -lws2_32 -lpng -lharfbuzz -lz -lopengl32 -lcomdlg32 -loleaut32 -limm32 -lwinmm -lglu32 -lopengl32" \
CGO_LDFLAGS="$CGO_LDFLAGS -lgdi32 -lole32 -luuid -lws2_32 -ladvapi32 -lshell32 -luser32 -lkernel32 -lmpr  -ldouble-conversion -lqtpcre -lqtharfbuzzng" \
CGO_LDFLAGS="$CGO_LDFLAGS -lQt5UiTools -lQt5Widgets -lQt5Gui -lQt5Core -lfontconfig -lexpat -lfreetype -lbz2 -lpng16 -lgdi32" \
CGO_LDFLAGS="$CGO_LDFLAGS -lqwindows  -lgdi32 -limm32 -loleaut32 -lwinmm -lQt5PlatformSupport -lfontconfig -lfreetype -lQt5Gui -lole32 -ljpeg -lpng -lharfbuzz -lz -lbz2 -lopengl32 -lQt5Core -lopengl32 -ldouble-conversion -lole32 -lgdi32" \
CC_FOR_TARGET="i686-w64-mingw32-gcc" CXX_FOR_TARGET="i686-w64-mingw32-g++" \
CGO_ENABLED=1 GOOS=windows GOARCH=386 go build -tags 'static' -o build/calculator.exe -v -x -ldflags "-H=windowsgui -linkmode external -s -w -extldflags=-static"
