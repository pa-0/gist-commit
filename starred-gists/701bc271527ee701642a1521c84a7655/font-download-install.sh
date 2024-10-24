#!/bin/bash

set -eux -o pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
DOWNLOAD_DIR="${SCRIPT_DIR}/downloads"
FILES_DIR="${SCRIPT_DIR}/files"

function download() {
    URL="$1"
    FILENAME=$(basename "$URL")
    echo "Download ${URL}"
    mkdir -p "${DOWNLOAD_DIR}"
    if [ ! -f "${DOWNLOAD_DIR}/${FILENAME}" ]; then
        curl -f -o "${DOWNLOAD_DIR}/${FILENAME}.tmp" -L "$URL"
        mv "${DOWNLOAD_DIR}/${FILENAME}.tmp" "${DOWNLOAD_DIR}/${FILENAME}"
    fi
}

function unarchive() {
    FILENAME=$(basename "$1")
    case "$FILENAME" in
        *.zip)
            BASENAME=$(basename "$FILENAME" .zip)
            UNARCHIVE_CMD=("unzip")
            ;;
        *.tar.gz)
            BASENAME=$(basename "$FILENAME" .tar.gz)
            UNARCHIVE_CMD=("tar" "xzf")
            ;;
        *.tar.xz)
            BASENAME=$(basename "$FILENAME" .tar.gz)
            UNARCHIVE_CMD=("tar" "xJf")
            ;;
        *)
            echo "Unsupported file type ${FILENAME}"
            exit 1
    esac
      
    if [ ! -d "${FILES_DIR}/${BASENAME}" ]; then
        mkdir -p "${FILES_DIR}/${BASENAME}.tmp"
        pushd "${FILES_DIR}/${BASENAME}.tmp"
        ${UNARCHIVE_CMD[@]} $1
        popd
        mv "${FILES_DIR}/${BASENAME}.tmp" "${FILES_DIR}/${BASENAME}"
    fi
}

function download-and-unarchive() {
    URL="$1"
    FILENAME=$(basename "$URL")
    
    download "$URL"
    unarchive "$DOWNLOAD_DIR/$FILENAME"
}

download-and-unarchive https://github.com/adobe-fonts/source-code-pro/releases/download/2.038R-ro%2F1.058R-it%2F1.018R-VAR/OTF-source-code-pro-2.038R-ro-1.058R-it.zip
download-and-unarchive https://github.com/adobe-fonts/source-han-sans/releases/download/2.004R/SourceHanSansJP.zip
download-and-unarchive https://github.com/adobe-fonts/source-han-serif/releases/download/2.001R/12_SourceHanSerifJP.zip
download-and-unarchive https://github.com/adobe-fonts/source-serif/releases/download/4.004R/source-serif-4.004.zip
download-and-unarchive https://github.com/adobe-fonts/source-sans/releases/download/3.046R/OTF-source-sans-3.046R.zip
download-and-unarchive https://github.com/IBM/plex/releases/download/v6.0.2/OpenType.zip
download-and-unarchive https://github.com/yuru7/HackGen/releases/download/v2.6.3/HackGenNerd_v2.6.3.zip
download-and-unarchive https://github.com/yuru7/HackGen/releases/download/v2.6.3/HackGen_v2.6.3.zip
download-and-unarchive https://github.com/yuru7/PlemolJP/releases/download/v1.2.5/PlemolJP_NF_v1.2.5.zip
download-and-unarchive https://github.com/yuru7/PlemolJP/releases/download/v1.2.5/PlemolJP_v1.2.5.zip
download-and-unarchive https://moji.or.jp/wp-content/ipafont/IPAexfont/IPAexfont00401.zip
download-and-unarchive https://moji.or.jp/wp-content/ipafont/IPAfont/IPAfont00303.zip
download-and-unarchive https://rictyfonts.github.io/files/ricty_diminished-4.1.1.tar.gz
download-and-unarchive https://osdn.net/dl/vlgothic/VLGothic-20220612.zip
download-and-unarchive https://github.com/domtronn/all-the-icons.el/archive/refs/tags/5.0.0.zip
download-and-unarchive https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
download-and-unarchive https://github.com/googlefonts/morisawa-biz-ud-mincho/releases/download/v1.05/morisawa-biz-ud-mincho-fonts.zip
download-and-unarchive https://github.com/googlefonts/morisawa-biz-ud-gothic/releases/download/v1.05/morisawa-biz-ud-gothic-fonts.zip
download-and-unarchive https://osdn.net/projects/mplus-fonts/downloads/62344/063-OTF.tar.xz
download-and-unarchive https://github.com/coz-m/MPLUS_FONTS/archive/refs/heads/master.zip
download-and-unarchive https://github.com/yuru7/udev-gothic/releases/download/v1.0.0/UDEVGothic_v1.0.0.zip
download-and-unarchive https://github.com/yuru7/udev-gothic/releases/download/v1.0.0/UDEVGothic_NF_v1.0.0.zip
download-and-unarchive https://github.com/Kinutafontfactory/Yuji/releases/download/3.000/Kinutafontfactory-Yuji-3_000.zip
download-and-unarchive https://github.com/googlefonts/zen-marugothic/archive/refs/heads/main.zip

sudo mkdir -p /usr/local/share/fonts/opentype/local
find "${FILES_DIR}" -name '*.otf' -a ! '(' -path '*/unhinted/*' -o -path '*/__MAXOSX/*' -o -name '._*' ')' -print0|sudo xargs -0 -I '{}' cp '{}' /usr/local/share/fonts/opentype/local

sudo mkdir -p /usr/local/share/fonts/truetype/local
find "${FILES_DIR}" -name '*.ttf' -a ! '(' -path '*/unhinted/*' -o -path '*/__MAXOSX/*' -o -name '._*' ')' -print0|sudo xargs -0 -I '{}' cp '{}' /usr/local/share/fonts/truetype/local
sudo find /usr/local/share/fonts -type f -print0|sudo xargs -0 chmod 644
sudo find /usr/local/share/fonts -type d -print0|sudo xargs -0 chmod 755

sudo fc-cache -f
