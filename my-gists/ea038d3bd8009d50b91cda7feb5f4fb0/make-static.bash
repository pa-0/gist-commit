#!/usr/bin/env bash

mkdir -p build

CHROOT="/usr/x86_64-pc-linux-gnu-static"
INCPATH="$CHROOT/usr/include/qt5"
PLUGPATH="$CHROOT/usr/lib/qt5/plugins"
export CC=gcc CXX=g++
export PKG_CONFIG_PATH="$CHROOT/usr/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$CHROOT/usr/lib/pkgconfig"
export LIBRARY_PATH="$CHROOT/usr/lib:$CHROOT/lib"

CGO_CXXFLAGS="-I$INCPATH -I$INCPATH/QtCore -I$INCPATH/QtGui -I$INCPATH/QtWidgets -I$INCPATH/QtUiTools" \
CGO_CXXFLAGS="$CGO_CXXFLAGS -pipe -O2 -std=gnu++11 -Wall -W -D_REENTRANT -DQT_NO_DEBUG -DQT_CORE_LIB -DQT_GUI_LIB -DQT_WIDGETS_LIB -DQT_UITOOLS_LIB -fPIC" \
CGO_LDFLAGS="-L$CHROOT/usr/lib -L$CHROOT/lib -L$PLUGPATH/platforms -L$PLUGPATH/generic" \
CGO_LDFLAGS="$CGO_LDFLAGS -lQt5Core -lpthread -lz -lpcre16 -ldouble-conversion -lm -ldl -lgthread-2.0 -lglib-2.0 -lrt" \
CGO_LDFLAGS="$CGO_LDFLAGS -ljpeg -lQt5Widgets -lQt5Gui -lQt5UiTools -lpthread -lpng -lharfbuzz -lz -lGL" \
CGO_LDFLAGS="$CGO_LDFLAGS -lfontconfig -lexpat -lfreetype -lfribidi -lbz2 -lpng16" \
CGO_LDFLAGS="$CGO_LDFLAGS -lqxcb -lqevdevkeyboardplugin -lqevdevmouseplugin -lQt5XcbQpa -lQt5PlatformSupport -lQt5DBus -lX11-xcb -lXi -lxcb-render -lxcb-render-util" \
CGO_LDFLAGS="$CGO_LDFLAGS -lSM -lICE -ldbus-1 -lxcb -lxcb-image -lxcb-icccm -lxcb-sync -lxcb-xfixes -lxcb-shm -lxcb-randr -lxcb-shape -lxcb-keysyms -lxcb-xinerama" \
CGO_LDFLAGS="$CGO_LDFLAGS -lxcb-xkb -lxcb-util -lxcb-glx -lxkbcommon-x11 -lxkbcommon  -lfontconfig -lfreetype -ldl -lXrender -lXext -lX11 -lm -ludev -lmtdev" \
CGO_LDFLAGS="$CGO_LDFLAGS -lEGL -lQt5Gui -ljpeg -lpng -lharfbuzz -lz -lbz2 -lGL -lQt5DBus -lQt5Core -lpthread -lGL" \
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -tags 'static' -o build/calculator -v -x
