#!/bin/sh

# This script get the various breeze icons used by an application
# and output a Qt plugin that can be statically linked using the
# official Qt plugin system. It makes applications more portable
# since they no longer require a valid icon theme to be installed.
#
# This is a *fallback* for platforms without an icon theme or with
# incomplete icon themes at the cost of a larger binary.
#
# Copyright Emmanuel Lepage 2015-2019
# LICENSE: BSD 3 clauses.

# Icon theme
ICON_THEME=/usr/share/icons/breeze

# Download the icons if they are not already installed
if [ ! -d "$ICON_THEME" ]; then
    if [ ! -d $PWD/breeze-icons ]; then
        git clone https://github.com/kde/breeze-icons
    fi
    ICON_THEME=$PWD/breeze-icons/icons
fi

LESSER2="<"

# Find all icons from the code

# Kirigami.Icon and Actions
KIRIGAMI_ICONS=$(git grep -E "(source:|iconName:)" -- .. |
    grep -vE "(qrc:|file:|image://)" | grep \" | cut -f2 -d\" | grep -vE "^:")

# QtGui QIcon
QTWIDGETS_ICONS=$(git grep -i fromTheme -- .. | grep -oE 'fromTheme[ (A-Za-z]*"[^"]+"' |
    grep -oE '"[^"]+"' | cut -f2 -d'"')

# KDeclarative icons
KDCL_ICONS=$(git grep 'image://icon/' -- .. | awk -F'(icon/|")' '{print $(NF-1)}')

# QtWidgets .ui XML files
UI_ICONS=$(git grep "${LESSER2}iconset theme=" -- .. | grep -oE '"[^"\[]+"' | cut -f2 -d'"')

# Kirigami tries to embded the icons it needs, but this doesn't seem very
# reliable and doesn't work on many macOS Kirigami apps available from
# Homebrew (like apt, but for Mac). It also fails on my Android dev env.
if [ "$(git grep 'import org.kde.kirigami' -- ..)" != "" ]; then
    KIRIGAMI_EXTRA=$(curl https://raw.githubusercontent.com/KDE/kirigami/master/kirigami-icons.qrc | 
        awk -F'(breeze-icons|.svg)' '{print $3}' | awk -F/ '{print $NF}')
fi

ICONS=$(echo -e "$QTWIDGETS_ICONS $UI_ICONS $KIRIGAMI_ICONS $KDCL_ICONS $KIRIGAMI_EXTRA" | sort | uniq)

# Bash and coreutils on macOS are ancient, use (the also ancient) python
function relativepath() {
   python -c "import os.path; print os.path.relpath('$1', '$ICON_THEME')"
}

mkdir -p iconpack

echo '<RCC>' > iconpack/icons.qrc
echo '  <qresource prefix="icons/breeze-internal">' >> iconpack/icons.qrc

for NAME in $ICONS; do
    echo "Searching $NAME"
    FILE=$(find $ICON_THEME -iname "${NAME}.*"| grep 22)

    if [ ! -e "$FILE" ]; then
        FILE=$(find $ICON_THEME -iname "${NAME}.*"| grep 16)
    fi

    if [ -e "$FILE" ]; then
        NEW_PATH=$(relativepath $FILE)
        mkdir -p iconpack/$(dirname $NEW_PATH)
        cp $FILE iconpack/$NEW_PATH
        echo FOUND $NEW_PATH
        echo '    <file>'$NEW_PATH'</file>' >> iconpack/icons.qrc
    else
        echo Not found
    fi
done

echo '    <file>index.theme</file>' >> iconpack/icons.qrc
echo '  </qresource>' >> iconpack/icons.qrc
echo '</RCC>' >> iconpack/icons.qrc

cat << EOF > iconpack/plugin.h
#include <QQmlExtensionPlugin>

class BreezeIconPack final : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.kde.breezeiconpack" FILE "breezeiconpack.json")

public:
    void registerTypes(const char *uri) override;
    virtual void initializeEngine(QQmlEngine* engine, const char* uri) override;
};
EOF

cat << EOF > iconpack/breezeiconpack.json
{
    "Keys": [ "org.kde.breezeiconpack" ],
    "uri": ["org.kde.breezeiconpack"]
}
EOF

cat << EOF > iconpack/plugin.cpp
#include "plugin.h"
#include <QQmlEngine>
#include "qrc_icons.cpp"
void BreezeIconPack::registerTypes(const char *uri) {}
void BreezeIconPack::initializeEngine(QQmlEngine *engine, const char *uri){}
EOF

cat << EOF > iconpack/CMakeLists.txt
cmake_minimum_required(VERSION 3.0)

project(breezeiconpack)

# When used with "add_subdirectory", assume it is a static Qt plugin
set(BUILD_SHARED_LIBS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

add_definitions(-DQT_PLUGIN)
add_definitions(-DQT_STATICPLUGIN=1)
add_definitions(-DGENERICUTILS_USE_STATIC_PLUGIN=1)

find_package(Qt5 CONFIG REQUIRED
    Core Gui Quick QuickControls2
)

set(GENERIC_LIB_VERSION "1.0.0")

#File to compile
set( breezeiconpack_LIB_SRCS
    plugin.cpp
)

qt5_add_resources(breezeiconpack_LIB_SRCS
    icons.qrc
)

set(AUTOMOC_MOC_OPTIONS -Muri=org.kde.breezeiconpack)

add_library(breezeiconpack STATIC \${breezeiconpack_LIB_SRCS} )

target_link_libraries( breezeiconpack
    # Qt
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Qt5::QuickControls2
)

# Configure the target config
set(breezeiconpack_CONFIG_PATH "\${CMAKE_CURRENT_BINARY_DIR}/BreezeIconPackConfig.cmake")

if(USES_ADD_SUBDIRECTORY)
   set(BreezeIconPack_DIR \${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
endif()

configure_package_config_file(
   "\${CMAKE_CURRENT_SOURCE_DIR}/cmake/BreezeIconPackConfig.cmake.in" \${breezeiconpack_CONFIG_PATH}
   INSTALL_DESTINATION \${CMAKE_INSTALL_FULL_LIBDIR}/cmake/BreezeIconPack/
   PATH_VARS INCLUDE_INSTALL_DIR
)

install( FILES \${breezeiconpack_CONFIG_PATH}
    DESTINATION \${CMAKE_INSTALL_FULL_LIBDIR}/cmake/BreezeIconPack/
    COMPONENT Devel
)

# Create the target
target_include_directories(breezeiconpack
    PUBLIC
        \$<INSTALL_INTERFACE:include/BreezeIconPack>
    PRIVATE
        \${CMAKE_CURRENT_SOURCE_DIR}/
)

export(TARGETS breezeiconpack
    FILE "\${PROJECT_BINARY_DIR}/cmake/BreezeIconPackTargets.cmake"
)

install(TARGETS breezeiconpack
    EXPORT BreezeIconPackTargets
    LIBRARY DESTINATION "\${CMAKE_INSTALL_FULL_LIBDIR}" COMPONENT breezeiconpack
    ARCHIVE DESTINATION \${CMAKE_INSTALL_FULL_LIBDIR}
    RUNTIME DESTINATION \${CMAKE_INSTALL_PREFIX}/bin
    COMPONENT Devel
)

install(EXPORT BreezeIconPackTargets
    DESTINATION \${CMAKE_INSTALL_FULL_LIBDIR}/cmake/BreezeIconPack
    COMPONENT Devel
)
EOF

mkdir -p iconpack/cmake

cat << EOF > iconpack/cmake/BreezeIconPackConfig.cmake.in
@PACKAGE_INIT@

add_definitions(-DHAS_ICON_PACK=1)

include("\${CMAKE_CURRENT_LIST_DIR}/BreezeIconPackTargets.cmake")
EOF

cat << EOF > iconpack/index.theme
[Icon Theme]
Name=Breeze

Comment=Default Plasma 5 Theme
DisplayDepth=32

Inherits=hicolor

Example=folder

FollowsColorScheme=true

DesktopDefault=22
DesktopSizes=22
ToolbarDefault=22
ToolbarSizes=22
MainToolbarDefault=22
MainToolbarSizes=22
SmallDefault=22
SmallSizes=22
PanelDefault=22
PanelSizes=22
DialogDefault=22
DialogSizes=22

KDE-Extensions=.svg

Directories=actions/22,apps/22,devices/22,emblems/22,emotes/22,mimetypes/22,places/22,status/22,actions/symbolic,devices/symbolic,emblems/symbolic,places/symbolic,status/symbolic

[actions/22]
Size=22
Context=Actions
Type=Scalable

[apps/22]
Size=22
Context=Applications
Type=Scalable

[categories/32]
Size=32
Context=Categories
Type=Scalable

[devices/22]
Size=22
Context=Devices
Type=Scalable

[emblems/22]
Size=22
Context=Emblems
Type=Scalable

[emotes/22]
Size=22
Context=Emotes
Type=Scalable

[mimetypes/22]
Size=22
Context=MimeTypes
Type=Scalable

[places/22]
Size=22
Context=Places
Type=Fixed

[status/22]
Size=22
Context=Status
Type=Scalable

EOF