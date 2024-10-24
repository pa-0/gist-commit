#!/bin/sh
latest=$(curl -sL https://ftpmirror.gnu.org/grep/ | grep -oE 'grep-[0-9]+\.[0-9]+(\.[0-9]+)?' | sort | tail -n 1)
wget "https://ftpmirror.gnu.org/grep/${latest}.tar.gz"
tar -xf "${latest}.tar.gz"
cd $latest
LDFLAGS=/usr/x86_64-w64-mingw32/lib/CRT_glob.o ./configure --target=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --build=x86_64-linux-gnu --enable-threads=windows
make -j$(nproc)
