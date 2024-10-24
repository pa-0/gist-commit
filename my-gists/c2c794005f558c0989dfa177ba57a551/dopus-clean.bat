@echo off
"C:\Program Files\GPSoftware\Directory Opus\DOpusRT.exe" /CMD Close PROGRAM
"C:\Program Files\GPSoftware\Directory Opus\DOpusRT.exe" /dblclk=off
ping 1.1.1.1 -n 1 -w 3000 > nul

del /F /Q "%userprofile%\AppData\Local\GPSoftware\Directory Opus\State Data\dupe.osd"
del /F /Q "%userprofile%\AppData\Local\GPSoftware\Directory Opus\State Data\find.osd"
del /F /Q "%userprofile%\AppData\Local\GPSoftware\Directory Opus\State Data\ftplast.osd"
del /F /Q "%userprofile%\AppData\Local\GPSoftware\Directory Opus\State Data\lastrename.osd"
del /F /Q "%userprofile%\AppData\Local\GPSoftware\Directory Opus\State Data\sync.osd"
del /F /Q /S "%userprofile%\AppData\Local\GPSoftware\Directory Opus\State Data\MRU*.*"