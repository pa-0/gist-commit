#!/bin/bash

VSCODE_OSX_LINK="https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
VSCODE_OSXARM_LINK="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64"
VSCODE_LINUX_LINK="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
VSCODE_WIN_LINK="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"

VSCODE_OSX_PATH=downloads/vscode-macos-x64
VSCODE_OSXARM_PATH=downloads/vscode-macos-arm
VSCODE_LINUX_PATH=downloads/vscode-linux-x64
VSCODE_WIN_PATH=downloads/vscode-win-x64

VSCODE_OSX_NAME=vscode-macos-x64
VSCODE_OSXARM_NAME=vscode-macos-arm
VSCODE_LINUX_NAME=vscode-linux-x64
VSCODE_WIN_NAME=vscode-win-x64

EDITED_DATA_PATH=vscode-main/data

VSCODE_MAC_URL=vscode-macos-x64
VSCODE_OSXARM_PATH_URL=vscode-macos-arm
VSCODE_LINUX_URL=vscode-linux-x64
MINGW_URL=https://netcologne.dl.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-win32/sjlj/x86_64-8.1.0-release-win32-sjlj-rt_v6-rev0.7z
CPPTOOLS_LINK=https://github.com/microsoft/vscode-cpptools/releases/download
CPPTOOLS_VERSION=v1.9.8
CPPTOOLS_WIN=cpptools-win64.vsix
CPPTOOLS_LINUX=cpptools-linux.vsix
CPPTOOLS_OSXARM=cpptools-osx-arm64.vsix
CPPTOOLS_OSX=cpptools-osx.vsix

check_error () {
    vscode_create_errors=$(( vscode_create_errors+$? ));
}

check_no_error () {
    vscode_create_errors=$(( vscode_create_errors+$? ));
    if [[ ! $vscode_create_errors = 0 ]];
    then
        error_msg
        exit 1
    fi
    ok_msg
}

folder_structure_msg () {
    error_msg
    echo "Make sure that the right folder structure exists:"
    echo "|"
    echo "|- $VSCODE_OSX_PATH"
    echo "|    |- Visual Studio Code.app"
    echo "|    |- ..."
    echo "|- $VSCODE_OSXARM_PATH"
    echo "|    |- Visual Studio Code.app"
    echo "|    |- ..."
    echo "|- $VSCODE_LINUX_PATH"
    echo "|    |- code"
    echo "|    |- ..."
    echo "|- $VSCODE_WIN_PATH"
    echo "|    |- Code.exe"
    echo "|    |- ..."
    echo "|- create_vscode.sh"
    exit 1
}

data_folder_msg () {
    error_msg
    echo "Data folder does not exist."
    echo "Was this repo cloned correctly?"
    exit 1
}

ok_msg () {
    echo -e "\e[32mDONE\e[0m"
}

error_msg () {
    echo -e "\e[31mERROR\e[0m"
}

help_msg() {
    echo "VSCode Portable Creator 1.0.0 by Eric Trenkel :)"
    echo "Usage: vscode_creator.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "      --prepare       Download VSCode for all platforms to prepare"
    echo "                      it for later"
    echo "      --pack          Pack everything up and create .zip files for"
    echo "                      every version"
    echo "      --clean         Clean EVERYTHING"
    exit 0
}

prepare() {
    # Downloading everything
    echo -n "Downloading VSCode...          "
    if [[ ! -f "$VSCODE_OSX_PATH.zip" ]] || \
        [[ ! -f "$VSCODE_OSXARM_PATH.zip" ]] || \
        [[ ! -f "$VSCODE_LINUX_PATH.tar.gz" ]] || \
        [[ ! -f "$VSCODE_WIN_PATH.zip" ]]
    then
        mkdir -p downloads
        wget  -q --show-progress $VSCODE_OSX_LINK -O $VSCODE_OSX_PATH.zip
        check_error
        wget  -q --show-progress $VSCODE_OSXARM_LINK -O $VSCODE_OSXARM_PATH.zip
        check_error
        wget  -q --show-progress $VSCODE_LINUX_LINK -O $VSCODE_LINUX_PATH.tar.gz
        check_error
        wget  -q --show-progress $VSCODE_WIN_LINK -O $VSCODE_WIN_PATH.zip
        check_error

        check_no_error
    else
        ok_msg
    fi

    # Check structure
    if [[ -d $VSCODE_OSX_PATH ||
            -d $VSCODE_OSXARM_PATH ||
            -d $VSCODE_LINUX_PATH ||
            -d $VSCODE_WIN_PATH ]]
    then
        error_msg
        echo "Some of the folders already exist."
        echo "Make sure that following folders do not exist yet before --preparing:"
        echo "|"
        echo "|- $VSCODE_OSX_PATH"
        echo "|- $VSCODE_OSXARM_PATH"
        echo "|- $VSCODE_LINUX_PATH"
        echo "|- $VSCODE_WIN_PATH"
        exit 1
    fi

    # Downloading everything
    echo -n "Extracting VSCode OSX...       "
    7z x -o$VSCODE_OSX_PATH $VSCODE_OSX_PATH.zip > /dev/null 2>&1
    check_no_error
    echo -n "Extracting VSCode OSX ARM...   "
    7z x -o$VSCODE_OSXARM_PATH $VSCODE_OSXARM_PATH.zip > /dev/null 2>&1
    check_no_error
    echo -n "Extracting VSCode Linux...     "
    7z x -o$VSCODE_LINUX_PATH-tmp1 $VSCODE_LINUX_PATH.tar.gz > /dev/null 2>&1
    check_error
    7z x -o$VSCODE_LINUX_PATH-tmp2 $VSCODE_LINUX_PATH-tmp1/$VSCODE_LINUX_NAME.tar > /dev/null 2>&1
    check_error
    # Sleep before continuing to avoid "Permission denied" error
    sleep 1
    mv $VSCODE_LINUX_PATH-tmp2/VSCode-linux-x64 $VSCODE_LINUX_PATH
    check_no_error
    echo -n "Extracting VSCode WIN...       "
    7z x -o$VSCODE_WIN_PATH $VSCODE_WIN_PATH.zip > /dev/null 2>&1
    check_no_error    

    # Check if right structure
    echo -n "Checking folder structure...   "
    if [[ ! -d "$VSCODE_OSX_PATH" ]] || \
        [[ ! -d "$VSCODE_OSXARM_PATH" ]] || \
        [[ ! -d "$VSCODE_LINUX_PATH" ]] || \
        [[ ! -d "$VSCODE_WIN_PATH" ]]
    then
        folder_structure_msg
    fi
    if [[ ! -d "$VSCODE_OSX_PATH/Visual Studio Code.app" ]] || \
        [[ ! -d "$VSCODE_OSXARM_PATH/Visual Studio Code.app" ]] || \
        [[ ! -f "$VSCODE_LINUX_PATH/code" ]] || \
        [[ ! -f "$VSCODE_WIN_PATH/Code.exe" ]]
    then
        folder_structure_msg
    fi
    ok_msg

    # Clean data folders
    echo -n "Cleaning data folders...       "
    if [[ $EDITED_DATA_PATH != $VSCODE_OSX_PATH/code-portable-data ]] && \
        [[ -d "$VSCODE_OSX_PATH/code-portable-data" ]]
    then
        rm -r "$VSCODE_OSX_PATH/code-portable-data"
    fi
    check_error
    if [[ $EDITED_DATA_PATH != $VSCODE_OSXARM_PATH/code-portable-data ]] && \
        [[ -d "$VSCODE_OSXARM_PATH/code-portable-data" ]]
    then
        rm -r "$VSCODE_OSXARM_PATH/code-portable-data"
    fi
    check_error
    if [[ $EDITED_DATA_PATH != $VSCODE_LINUX_PATH/data ]] && \
        [[ -d "$VSCODE_LINUX_PATH/data" ]]
    then
        rm -r "$VSCODE_LINUX_PATH/data"
    fi
    check_error
    if [[ $EDITED_DATA_PATH != $VSCODE_WIN_PATH/data ]] && \
        [[ -d "$VSCODE_WIN_PATH/data" ]]
    then
        rm -r "$VSCODE_WIN_PATH/data"
    fi
    check_error

    check_no_error

    # Creating data folders
    echo -n "Creating data folders...       "
    mkdir -p "$VSCODE_OSX_PATH/code-portable-data/user-data/User"
    check_error
    mkdir -p "$VSCODE_OSX_PATH/code-portable-data/extensions"
    check_error
    mkdir -p "$VSCODE_OSXARM_PATH/code-portable-data/user-data/User"
    check_error
    mkdir -p "$VSCODE_OSXARM_PATH/code-portable-data/extensions"
    check_error
    mkdir -p "$VSCODE_LINUX_PATH/data/user-data/User"
    check_error
    mkdir -p "$VSCODE_LINUX_PATH/data/extensions"
    check_error
    mkdir -p "$VSCODE_WIN_PATH/data/user-data/User"
    check_error
    mkdir -p "$VSCODE_WIN_PATH/data/extensions"
    check_error

    check_no_error

    # Clean up temp
    echo -n "Cleaning up temp...            "
    rm -r $VSCODE_LINUX_PATH-tmp1
    check_error
    rm -r $VSCODE_LINUX_PATH-tmp2
    check_error

    check_no_error

    # Get current OS
    echo -n "Copying OS folder...          "
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        # Check if mac arm
        if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm"* ]]
        then
            cp -r $VSCODE_OSXARM_PATH ${EDITED_DATA_PATH/\/data}
        else
            cp -r $VSCODE_OSX_PATH ${EDITED_DATA_PATH/\/data}
        fi
    elif [[ "$OSTYPE" == "linux-gnu" ]]
    then
        OS="linux"
        cp -r $VSCODE_LINUX_PATH ${EDITED_DATA_PATH/\/data}
    elif [[ "$OSTYPE" == "msys" ]]
    then
        OS="win"
        cp -r $VSCODE_WIN_PATH ${EDITED_DATA_PATH/\/data}
    else
        echo "Unknown OS. Copy your OS folder manually."
        exit
    fi
    check_no_error
    echo "You can now open VSCode from ${EDITED_DATA_PATH/\/data} and start editing the settings."
    echo "Once done you can continue with the --pack command."
}

pack () {
    # Check if right structure
    echo -n "Checking folder structure...   "
    if [[ ! -d "$VSCODE_OSX_PATH" ]] || \
        [[ ! -d "$VSCODE_OSXARM_PATH" ]] || \
        [[ ! -d "$VSCODE_LINUX_PATH" ]] || \
        [[ ! -d "$VSCODE_WIN_PATH" ]]
    then
        folder_structure_msg
    fi
    if [[ ! -d "$VSCODE_OSX_PATH/Visual Studio Code.app" ]] || \
        [[ ! -d "$VSCODE_OSXARM_PATH/Visual Studio Code.app" ]] || \
        [[ ! -f "$VSCODE_LINUX_PATH/code" ]] || \
        [[ ! -f "$VSCODE_WIN_PATH/Code.exe" ]]
    then
        folder_structure_msg
    fi
    ok_msg

    #echo "Enter path to data folder from edited VSCode: (e.g. downloads/vscode-win-x64/data)"
    #read EDITED_DATA_PATH

    if [[ ! -n $EDITED_DATA_PATH ]]
    then
        error_msg
        echo "Edited VSCode folder does not exist".
        exit 1
    fi

    # Check if data folder exists
    echo -n "Checking data folder...        "
    if [[ ! -d "$EDITED_DATA_PATH" ]]
    then
        data_folder_msg
    fi
    ok_msg
    
    # Copy settings to data folders
    echo -n "Copying settings...            "
    cp -R -u -n $EDITED_DATA_PATH/user-data/User/settings.json "$VSCODE_OSX_PATH/code-portable-data/user-data/User"
    check_error
    cp -R -u -n $EDITED_DATA_PATH/user-data/User/settings.json "$VSCODE_OSXARM_PATH/code-portable-data/user-data/User"
    check_error
    cp -R -u -n $EDITED_DATA_PATH/user-data/User/settings.json "$VSCODE_LINUX_PATH/data/user-data/User"
    check_error
    cp -R -u -n $EDITED_DATA_PATH/user-data/User/settings.json "$VSCODE_WIN_PATH/data/user-data/User"
    check_error

    check_no_error

    # Copy extensions to data folders
    echo -n "Copying extensions...          "
    subfolders=$(ls $EDITED_DATA_PATH/extensions/)
    # Has extensions
    if (( ${#subfolders} > 0 ))
    then
        for extension in $EDITED_DATA_PATH/extensions/*;
        do
            extension_name=${extension//$EDITED_DATA_PATH\/extensions\/};
            if [[ $extension_name != *"linux"* ]] && \
                [[ $extension_name != *"win"* ]] && \
                [[ $extension_name != *"darwin"* ]]
            then
                cp -R -u -n $extension $VSCODE_OSX_PATH/code-portable-data/extensions/
                check_error
                cp -R -u -n $extension $VSCODE_OSXARM_PATH/code-portable-data/extensions/
                check_error
                cp -R -u -n $extension $VSCODE_LINUX_PATH/data/extensions/
                check_error
                cp -R -u -n $extension $VSCODE_WIN_PATH/data/extensions/
                check_error
            fi
        done
    fi

    check_no_error

    # Download custom GIP extension
    echo -n "Downloading GIP extension...   "
    wget -O downloads/gip-extension.vsix https://github.com/bostrot/vscode-gip-project/blob/main/gip-projekt-latest.vsix?raw=true
    check_no_error
    echo -n "Extracting GIP extension...    "
    7z x -aoa -bb0 -o$VSCODE_WIN_PATH/data/extensions/gip-extension \
        downloads/gip-extension.vsix  # > /dev/null 2>&1
    check_no_error
    echo -n "Copying GIP extension...       "
    cp -R $VSCODE_WIN_PATH/data/extensions/gip-extension \
            $VSCODE_OSX_PATH/code-portable-data/extensions/gip-extension
    cp -R $VSCODE_WIN_PATH/data/extensions/gip-extension \
            $VSCODE_OSXARM_PATH/code-portable-data/extensions/gip-extension
    cp -R $VSCODE_WIN_PATH/data/extensions/gip-extension \
            $VSCODE_LINUX_PATH/data/extensions/gip-extension
    check_no_error

    # Download cpptools
    echo -n "Getting cpptools...            "
    wget  -q --show-progress $CPPTOOLS_LINK/$CPPTOOLS_VERSION/$CPPTOOLS_WIN -O downloads/$CPPTOOLS_WIN
    check_error
    wget  -q --show-progress $CPPTOOLS_LINK/$CPPTOOLS_VERSION/$CPPTOOLS_LINUX -O downloads/$CPPTOOLS_LINUX
    check_error
    wget  -q --show-progress $CPPTOOLS_LINK/$CPPTOOLS_VERSION/$CPPTOOLS_OSXARM -O downloads/$CPPTOOLS_OSXARM
    check_error
    wget  -q --show-progress $CPPTOOLS_LINK/$CPPTOOLS_VERSION/$CPPTOOLS_OSX -O downloads/$CPPTOOLS_OSX
    check_error

    check_no_error

    # Extract cpptools
    echo -n "Extracting cpptools...         "
    7z x -aoa -bb0 -o$VSCODE_WIN_PATH/data/extensions/ms-vscode.cpptools-$CPPTOOLS_VERSION-$CPPTOOLS_WIN \
        downloads/$CPPTOOLS_WIN  # > /dev/null 2>&1
    check_error
    7z x -aoa -bb0 -o$VSCODE_LINUX_PATH/data/extensions/ms-vscode.cpptools-$CPPTOOLS_VERSION-$CPPTOOLS_LINUX \
        downloads/$CPPTOOLS_LINUX  # > /dev/null 2>&1
    check_error
    7z x -aoa -bb0 -o$VSCODE_OSXARM_PATH/code-portable-data/extensions/ms-vscode.cpptools-$CPPTOOLS_VERSION-$CPPTOOLS_OSXARM \
        downloads/$CPPTOOLS_OSXARM  # > /dev/null 2>&1
    check_error
    7z x -aoa -bb0 -o$VSCODE_OSX_PATH/code-portable-data/extensions/ms-vscode.cpptools-$CPPTOOLS_VERSION-$CPPTOOLS_OSX \
        downloads/$CPPTOOLS_OSX  # > /dev/null 2>&1
    check_error

    check_no_error

    # Download mingw for windows
    echo -n "Getting mingw for windows...   "
    check_error
    wget  -q --show-progress $MINGW_URL -O downloads/mingw.7z
    check_error
    7z x -aoa -bb0 -o"$VSCODE_WIN_PATH" downloads/mingw.7z # > /dev/null 2>&1
    mv $VSCODE_WIN_PATH/mingw64 $VSCODE_WIN_PATH/mingw
    check_error

    check_no_error

    # Pack everything
    echo -n "Packing everything...          "
    mkdir -p releases
    7z a -aoa -bb0 -tzip releases/$VSCODE_OSX_NAME.zip ./$VSCODE_OSX_PATH/* # > /dev/null 2>&1
    check_error
    7z a -aoa -bb0 -tzip releases/$VSCODE_OSXARM_NAME.zip ./$VSCODE_OSXARM_PATH/* # > /dev/null 2>&1
    check_error
    7z a -aoa -bb0 -tzip releases/$VSCODE_LINUX_NAME.zip ./$VSCODE_LINUX_PATH/* # > /dev/null 2>&1
    check_error
    7z a -aoa -bb0 -tzip releases/$VSCODE_WIN_NAME.zip ./$VSCODE_WIN_PATH/* # > /dev/null 2>&1
    check_error

    check_no_error
}

clean () {
    # Clean up everything
    echo -n "Cleaning up...                 "
    rm -r downloads/
    check_error

    check_no_error
}

vscode_create_errors=0


# Check dependencies
echo -n "Checking dependencies...       "
if ! $(7z --help > /dev/null 2>&1)
then
    error_msg
    check_error
    echo "7z not installed."
    exit 1
fi
if ! $(wget --help > /dev/null 2>&1)
then
    error_msg
    echo "wget not installed."
    exit 1
fi
ok_msg


if [[ ! -n $1 ]]
then
    help_msg
elif [[ $1 == "--prepare" ]]
then
    prepare
    exit 0
elif [[ $1 == "--pack" ]]
then
    pack
    exit 0
elif [[ $1 == "--clean" ]]
then
    clean
    exit 0
elif [[ $1 == "--create" ]]
then
    prepare
    VSCODE_WIN_PATH/Code.exe
    pack
    exit 0
fi

help_msg
