@echo off
setlocal

set PortableApps.comDisableSplash=true
set PortableApps.comLanguageCode=ja
set PortableApps.comLanguageCode_INTERNAL=ja
set PortableApps.comLanguageCode2=ja
set PortableApps.comLanguageCode2_INTERNAL=ja
set PortableApps.comLanguageCode3=jpn
set PortableApps.comLanguageCode3_INTERNAL=jpn
set PortableApps.comLanguageGlibc=ja
set PortableApps.comLanguageGlibc_INTERNAL=ja
set PortableApps.comLanguageLCID=1041
set PortableApps.comLanguageLCID_INTERNAL=1041
set PortableApps.comLanguageName=Japanese
set PortableApps.comLanguageName_INTERNAL=Japanese
set PortableApps.comLanguageNSIS=LANG_JAPANESE
set PortableApps.comLanguageNSIS_INTERNAL=LANG_JAPANESE
set PortableApps.comLocaleCode2=ja
set PortableApps.comLocaleCode2_INTERNAL=ja
set PortableApps.comLocaleCode3=jpn
set PortableApps.comLocaleCode3_INTERNAL=jpn
set PortableApps.comLocaleglibc=ja
set PortableApps.comLocaleglibc_INTERNAL=ja
set PortableApps.comLocaleID=1041
set PortableApps.comLocaleID_INTERNAL=1041
set PortableApps.comLocaleWinName=LANG_JAPANESE
set PortableApps.comLocaleWinName_INTERNAL=LANG_JAPANESE

pushd %~d0\PortableApps\PortableApps.com
start %~d0\PortableApps\PortableApps.com\PortableAppsUpdater.exe ^
        /STARTUP=true           ^
        /MODE=UPDATE            ^
        /KEYBOARDFRIENDLY=false ^
        /HIDEPORTABLE=true      ^
        /BETA=false             ^
        /CONNECTION=Automatic
popd

endlocal
