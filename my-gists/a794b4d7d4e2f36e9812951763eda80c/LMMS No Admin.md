### Install LMMS without Admin
1. Download [7zip](https://portableapps.com/apps/utilities/7-zip_portable) portable, extract to the Desktop
2. Download LMMS
3. Open a command prompt, paste in the following:
   ```cmd
   %USERPROFILE%\Desktop\7-ZipPortable\App\7-Zip\7z.exe x %USERPROFILE%\Downloads\lmms-1.2.0-rc6-win64.exe -x!$PLUGINSDIR -o%USERPROFILE%\Desktop\LMMS
   ```

4. Should output this:

   ```log
   7-Zip [32] 16.04 : Copyright (c) 1999-2016 Igor Pavlov : 2016-10-04

   Scanning the drive for archives:
   1 file, 34240067 bytes (33 MiB)

   Extracting archive: Downloads\lmms-1.2.0-rc3-win64.exe
   --
   Path = Downloads\lmms-1.2.0-rc6-win64.exe
   Type = Nsis
   Physical Size = 34240067
   Method = LZMA:23
   Solid = -
   Headers Size = 319278
   Embedded Stub Size = 207360
   SubType = NSIS-2

   Everything is Ok

   Files: 2921
   Size:       96058620
   Compressed: 34240067
   ```
5.  Run `lmms.exe` from the folder created on the desktop.
6.  Optionally, delete leftover files from Downloads, etc.