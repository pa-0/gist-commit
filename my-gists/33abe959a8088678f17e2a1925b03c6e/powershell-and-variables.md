# PowerShell and variables

Every script I write has variables in it, but there are different types of variables. This short blog post will show a few types you can use in your scripts.

- [PowerShell and variables](#powershell-and-variables)
  - [What are variables?](#what-are-variables)
  - [Array](#array)
  - [Environment variables](#environment-variables)
  - [Hash table](#hash-table)
  - [Int32/64](#int3264)
  - [String](#string)

## What are variables?

You can store all types of values in PowerShell variables. For example, store the results of commands and elements used in commands and expressions, such as names, paths, settings, and values.

A variable is a unit of memory in which values are stored. In PowerShell, variables are represented by text strings that begin with a dollar sign ($), such as $a, $process, or $my_var.

Variable names aren't case-sensitive and can include spaces and special characters.

## Array

This is something that I use a lot. An array is a list of items that you can use, for example:

```powershell
$files=Get-ChildItem -Path d:\temp -Filter *.ps1
$files=Get-ChildItem -Path d:\temp -Filter*.ps1
$files=Get-ChildItem -Path d:\temp -Filter *.ps1
This will search for all*.ps1 files in d:\temp and store the found items in the $files array. You can check what type the variable is by adding ".GetType()" behind it. This looks like this:
```

The BaseType tells you that it's an Array, and the contents of the Array can be listed by running $files in our example:

```powershell
Mode LastWriteTime Length Name
---- ------------- ------ ----
-a--- 29-8-2022 22:24 1481 ﲵ 365healthstatus.ps1
-a--- 25-2-2022 14:30 261 ﲵ Activation.ps1
-a--- 14-7-2022 12:26 4630 ﲵ AdminGroupChangeReport.ps1
-a--- 16-6-2022 13:28 746 ﲵ AdminGroups.ps1
-a--- 26-8-2021 12:49 5455 ﲵ AdminReport.ps1
-a--- 27-10-2021 10:08 14672 ﲵ AppleDEPProfile_Assign.ps1
-a--- 2-11-2021 15:24 9569 ﲵ applevpp_sync.ps1
-a--- 15-10-2020 14:19 2523 ﲵ BIOS_Settings_For_HP.ps1
-a--- 20-1-2022 15:47 142 ﲵ bitlocker.ps1
-a--- 20-1-2022 13:49 64 ﲵ bitlockerremediate.ps1
-a--- 20-1-2022 13:49 192 ﲵ bitlockertest.ps1
-a--- 22-5-2022 21:10 488 ﲵ calendar_events.ps1
C:\Users\HarmV> $files Directory: D:\Temp Mode LastWriteTime Length Name ---- ------------- ------ ---- -a--- 29-8-2022 22:24 1481 ﲵ 365healthstatus.ps1 -a--- 25-2-2022 14:30 261 ﲵ Activation.ps1 -a--- 14-7-2022 12:26 4630 ﲵ AdminGroupChangeReport.ps1 -a--- 16-6-2022 13:28 746 ﲵ AdminGroups.ps1 -a--- 26-8-2021 12:49 5455 ﲵ AdminReport.ps1 -a--- 27-10-2021 10:08 14672 ﲵ AppleDEPProfile_Assign.ps1 -a--- 2-11-2021 15:24 9569 ﲵ applevpp_sync.ps1 -a--- 15-10-2020 14:19 2523 ﲵ BIOS_Settings_For_HP.ps1 -a--- 20-1-2022 15:47 142 ﲵ bitlocker.ps1 -a--- 20-1-2022 13:49 64 ﲵ bitlockerremediate.ps1 -a--- 20-1-2022 13:49 192 ﲵ bitlockertest.ps1 -a--- 22-5-2022 21:10 488 ﲵ calendar_events.ps1 ...
C:\Users\HarmV> $files

        Directory: D:\Temp

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---         29-8-2022     22:24           1481 ﲵ  365healthstatus.ps1
-a---         25-2-2022     14:30            261 ﲵ  Activation.ps1
-a---         14-7-2022     12:26           4630 ﲵ  AdminGroupChangeReport.ps1
-a---         16-6-2022     13:28            746 ﲵ  AdminGroups.ps1
-a---         26-8-2021     12:49           5455 ﲵ  AdminReport.ps1
-a---        27-10-2021     10:08          14672 ﲵ  AppleDEPProfile_Assign.ps1
-a---         2-11-2021     15:24           9569 ﲵ  applevpp_sync.ps1
-a---        15-10-2020     14:19           2523 ﲵ  BIOS_Settings_For_HP.ps1
-a---         20-1-2022     15:47            142 ﲵ  bitlocker.ps1
-a---         20-1-2022     13:49             64 ﲵ  bitlockerremediate.ps1
-a---         20-1-2022     13:49            192 ﲵ  bitlockertest.ps1
-a---         22-5-2022     21:10            488 ﲵ  calendar_events.ps1
...
```

You can use the array in a ForEach loop to do something to each individual item in it, for example:

```powershell
C:\Users\HarmV> foreach ($file in $files) {Write-Host $file.FullName}
D:\Temp\365healthstatus.ps1
D:\Temp\AdminGroupChangeReport.ps1
D:\Temp\AppleDEPProfile_Assign.ps1
D:\Temp\applevpp_sync.ps1
D:\Temp\BIOS_Settings_For_HP.ps1
D:\Temp\bitlockerremediate.ps1
D:\Temp\bitlockertest.ps1
D:\Temp\calendar_events.ps1
C:\Users\HarmV> foreach ($file in $files) {Write-Host $file.FullName} D:\Temp\365healthstatus.ps1 D:\Temp\Activation.ps1 D:\Temp\AdminGroupChangeReport.ps1 D:\Temp\AdminGroups.ps1 D:\Temp\AdminReport.ps1 D:\Temp\AppleDEPProfile_Assign.ps1 D:\Temp\applevpp_sync.ps1 D:\Temp\BIOS_Settings_For_HP.ps1 D:\Temp\bitlocker.ps1 D:\Temp\bitlockerremediate.ps1 D:\Temp\bitlockertest.ps1 D:\Temp\calendar_events.ps1
C:\Users\HarmV> foreach ($file in $files) {Write-Host $file.FullName}
D:\Temp\365healthstatus.ps1
D:\Temp\Activation.ps1
D:\Temp\AdminGroupChangeReport.ps1
D:\Temp\AdminGroups.ps1
D:\Temp\AdminReport.ps1
D:\Temp\AppleDEPProfile_Assign.ps1
D:\Temp\applevpp_sync.ps1
D:\Temp\BIOS_Settings_For_HP.ps1
D:\Temp\bitlocker.ps1
D:\Temp\bitlockerremediate.ps1
D:\Temp\bitlockertest.ps1
D:\Temp\calendar_events.ps1
```

If you want to select a specific item from the array, for example, the second one, you can use: (It starts counting at zero, so the second item is one )

```powershell
C:\Users\HarmV> $files[1]
Mode LastWriteTime Length Name
---- ------------- ------ ----
-a--- 25-2-2022 14:30 261 ﲵ Activation.ps1
C:\Users\HarmV> $files[1] Directory: D:\Temp Mode LastWriteTime Length Name ---- ------------- ------ ---- -a--- 25-2-2022 14:30 261 ﲵ Activation.ps1
C:\Users\HarmV> $files[1]

        Directory: D:\Temp

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---         25-2-2022     14:30            261 ﲵ  Activation.ps1
You can create an array with your own items by running this:

$array=@( "Item 1" "Item 2" "Item 3" )
$array=@(
 "Item 1"
 "Item 2"
 "Item 3"
)
```

You can query/view it like this:

```powershell
C:\Users\HarmV> $array.GetType()
IsPublic IsSerial Name BaseType
-------- -------- ---- --------
True True Object[] System.Array
C:\Users\HarmV> $array[1]
C:\Users\HarmV> $array.GetType() IsPublic IsSerial Name BaseType -------- -------- ---- -------- True True Object[] System.Array C:\Users\HarmV> $array Item 1 Item 2 Item 3 C:\Users\HarmV> $array[1] Item 2
C:\Users\HarmV> $array.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Object[]                                 System.Array

C:\Users\HarmV> $array
Item 1
Item 2
Item 3
C:\Users\HarmV> $array[1]
Item 2
```

## Environment variables

These are always available and will contain system or user-specific settings. Examples are: (Type $env: followed by Tab)

```powershell
__COMPAT_LAYER NUMBER_OF_PROCESSORS ProgramFiles(x86)
ALLUSERSPROFILE OneDrive ProgramW6432
APPDATA OneDriveCommercial PSModulePath
ChocolateyInstall OneDriveConsumer PUBLIC
ChocolateyLastPathUpdate OS SystemDrive
COLUMNS PARSER_FILES_PATH SystemRoot
CommonProgramFiles Path TEMP
CommonProgramFiles(x86) PATHEXT TMP
CommonProgramW6432 POSH_THEMES_PATH USERDOMAIN
COMPUTERNAME POWERSHELL_DISTRIBUTION_CHANNEL USERDOMAIN_ROAMINGPROFILE
ComSpec PROCESSOR_ARCHITECTURE USERNAME
DriverData PROCESSOR_IDENTIFIER USERPROFILE
HOMEDRIVE PROCESSOR_LEVEL windir
HOMEPATH PROCESSOR_REVISION WSLENV
LOCALAPPDATA ProgramData WT_PROFILE_ID
LOGONSERVER ProgramFiles WT_SESSION
C:\Users\HarmV> $env:__COMPAT_LAYER NUMBER_OF_PROCESSORS ProgramFiles(x86) ALLUSERSPROFILE OneDrive ProgramW6432 APPDATA OneDriveCommercial PSModulePath ChocolateyInstall OneDriveConsumer PUBLIC ChocolateyLastPathUpdate OS SystemDrive COLUMNS PARSER_FILES_PATH SystemRoot CommonProgramFiles Path TEMP CommonProgramFiles(x86) PATHEXT TMP CommonProgramW6432 POSH_THEMES_PATH USERDOMAIN COMPUTERNAME POWERSHELL_DISTRIBUTION_CHANNEL USERDOMAIN_ROAMINGPROFILE ComSpec PROCESSOR_ARCHITECTURE USERNAME DriverData PROCESSOR_IDENTIFIER USERPROFILE HOMEDRIVE PROCESSOR_LEVEL windir HOMEPATH PROCESSOR_REVISION WSLENV LOCALAPPDATA ProgramData WT_PROFILE_ID LOGONSERVER ProgramFiles WT_SESSION
C:\Users\HarmV> $env:
__COMPAT_LAYER                   NUMBER_OF_PROCESSORS             ProgramFiles(x86)
ALLUSERSPROFILE                  OneDrive                         ProgramW6432
APPDATA                          OneDriveCommercial               PSModulePath
ChocolateyInstall                OneDriveConsumer                 PUBLIC
ChocolateyLastPathUpdate         OS                               SystemDrive
COLUMNS                          PARSER_FILES_PATH                SystemRoot
CommonProgramFiles               Path                             TEMP
CommonProgramFiles(x86)          PATHEXT                          TMP
CommonProgramW6432               POSH_THEMES_PATH                 USERDOMAIN
COMPUTERNAME                     POWERSHELL_DISTRIBUTION_CHANNEL  USERDOMAIN_ROAMINGPROFILE
ComSpec                          PROCESSOR_ARCHITECTURE           USERNAME
DriverData                       PROCESSOR_IDENTIFIER             USERPROFILE
HOMEDRIVE                        PROCESSOR_LEVEL                  windir
HOMEPATH                         PROCESSOR_REVISION               WSLENV
LOCALAPPDATA                     ProgramData                      WT_PROFILE_ID
LOGONSERVER                      ProgramFiles                     WT_SESSION
```

You can use this as an example to show the location of your personal or work OneDrive folders:

```powershell
C:\Users\HarmV> $env:OneDriveCommercial
C:\Users\HarmV\OneDrive - NEXXT
C:\Users\HarmV> $env:OneDriveConsumer
C:\Users\HarmV> $env:OneDriveCommercial C:\Users\HarmV\OneDrive - NEXXT C:\Users\HarmV> $env:OneDriveConsumer C:\Users\HarmV\OneDrive
C:\Users\HarmV> $env:OneDriveCommercial
C:\Users\HarmV\OneDrive - NEXXT
C:\Users\HarmV> $env:OneDriveConsumer
C:\Users\HarmV\OneDrive
```

It's basically system variables you can use in scripts so that you don't hardcode specific paths. It might be that c:\users\public is remapped to d:\users\public, and your scripts will fail if you don't use the $env:public variable.

## Hash table

A hash table is a data structure of key and value pairs. You can create one using the following:

```powershell
$hashtable=@{ "Android" = "Google" "iOS" = "Apple" "MacOS"= "Apple" "Windows" = "Microsoft" }
$hashtable=@{
 "Android" = "Google"
 "iOS" = "Apple"
 "MacOS"= "Apple"
 "Windows" = "Microsoft"
}
```

This will look like this:

```powershell
C:\Users\HarmV> $hashtable
C:\Users\HarmV> $hashtable Name Value ---- ----- MacOS Apple iOS Apple Windows Microsoft Android Google
C:\Users\HarmV> $hashtable

Name                           Value
----                           -----
MacOS                          Apple
iOS                            Apple
Windows                        Microsoft
Android                        Google
You can search for a certain value by using the following to get all values that contain Apple:

C:\Users\HarmV> $hashtable.GetEnumerator().Where({$_.Value -contains 'Apple'})
C:\Users\HarmV> $hashtable.GetEnumerator().Where({$_.Value -contains 'Apple'}) Name Value ---- ----- MacOS Apple iOS Apple
C:\Users\HarmV> $hashtable.GetEnumerator().Where({$_.Value -contains 'Apple'})

Name                           Value
----                           -----
MacOS                          Apple
iOS                            Apple
```

## Int32/64

You can store numbers in variables, for example:

```powershell
C:\Users\HarmV> $number=1
C:\Users\HarmV> $number.GetType()
IsPublic IsSerial Name BaseType
-------- -------- ---- --------
True True Int32 System.ValueType
C:\Users\HarmV> $number=1 C:\Users\HarmV> $number.GetType() IsPublic IsSerial Name BaseType -------- -------- ---- -------- True True Int32 System.ValueType
C:\Users\HarmV> $number=1
C:\Users\HarmV> $number.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Int32                                    System.ValueType

You can do math with this as well, for example:

C:\Users\HarmV> $number*8
C:\Users\HarmV> $number*8 8
C:\Users\HarmV> $number*8
8
```

You can also add 1 to an existing number variable. I use this to show progress in a script. For example:

```powershell
$files=Get-ChildItem -Path d:\temp -Filter *.ps1
foreach ($file in $files) {
Write-Host ("[{0}/{1}] Found {2}" -f $count, $files.count, $file.fullname)
$count=1 $files=Get-ChildItem -Path d:\temp -Filter*.ps1 foreach ($file in $files) { Write-Host ("[{0}/{1}] Found {2}" -f $count, $files.count, $file.fullname) $count++ }
$count=1
$files=Get-ChildItem -Path d:\temp -Filter *.ps1
foreach ($file in $files) {
Write-Host ("[{0}/{1}] Found {2}" -f $count, $files.count, $file.fullname)
$count++
}
```

This will show an output that looks like this:

```powershell
[1/49] Found D:\Temp\365healthstatus.ps1
[2/49] Found D:\Temp\Activation.ps1
[3/49] Found D:\Temp\AdminGroupChangeReport.ps1
[4/49] Found D:\Temp\AdminGroups.ps1
[5/49] Found D:\Temp\AdminReport.ps1
[6/49] Found D:\Temp\AppleDEPProfile_Assign.ps1
[7/49] Found D:\Temp\applevpp_sync.ps1
[8/49] Found D:\Temp\BIOS_Settings_For_HP.ps1
[9/49] Found D:\Temp\bitlocker.ps1
[10/49] Found D:\Temp\bitlockerremediate.ps1
[11/49] Found D:\Temp\bitlockertest.ps1
[12/49] Found D:\Temp\calendar_events.ps1
[1/49] Found D:\Temp\365healthstatus.ps1 [2/49] Found D:\Temp\Activation.ps1 [3/49] Found D:\Temp\AdminGroupChangeReport.ps1 [4/49] Found D:\Temp\AdminGroups.ps1 [5/49] Found D:\Temp\AdminReport.ps1 [6/49] Found D:\Temp\AppleDEPProfile_Assign.ps1 [7/49] Found D:\Temp\applevpp_sync.ps1 [8/49] Found D:\Temp\BIOS_Settings_For_HP.ps1 [9/49] Found D:\Temp\bitlocker.ps1 [10/49] Found D:\Temp\bitlockerremediate.ps1 [11/49] Found D:\Temp\bitlockertest.ps1 [12/49] Found D:\Temp\calendar_events.ps1
[1/49] Found D:\Temp\365healthstatus.ps1
[2/49] Found D:\Temp\Activation.ps1
[3/49] Found D:\Temp\AdminGroupChangeReport.ps1
[4/49] Found D:\Temp\AdminGroups.ps1
[5/49] Found D:\Temp\AdminReport.ps1
[6/49] Found D:\Temp\AppleDEPProfile_Assign.ps1
[7/49] Found D:\Temp\applevpp_sync.ps1
[8/49] Found D:\Temp\BIOS_Settings_For_HP.ps1
[9/49] Found D:\Temp\bitlocker.ps1
[10/49] Found D:\Temp\bitlockerremediate.ps1
[11/49] Found D:\Temp\bitlockertest.ps1
[12/49] Found D:\Temp\calendar_events.ps1
```

## String

A string is a simple object with a value, for example:

```powershell
$string="Hello world"
This is displayed as:

C:\Users\HarmV> $string Hello world
C:\Users\HarmV> $string
Hello world
```

And you can see it's an object:

```powershell
C:\Users\HarmV> $string.GetType()
IsPublic IsSerial Name BaseType
-------- -------- ---- --------
True True String System.Object
C:\Users\HarmV> $string.GetType() IsPublic IsSerial Name BaseType -------- -------- ---- -------- True True String System.Object
C:\Users\HarmV> $string.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     String                                   System.Object
You can combine two strings in your output like this:

C:\Users\HarmV> $string2="!"
C:\Users\HarmV> Write-Host $string$string2
C:\Users\HarmV> $string2="!" C:\Users\HarmV> Write-Host $string$string2 Hello world!
C:\Users\HarmV> $string2="!"
C:\Users\HarmV> Write-Host $string$string2
Hello world!

Or join two strings together like this using -join with the space separator using " "

C:\Users\HarmV> $string1="Good"
C:\Users\HarmV> $string2="Evening"
C:\Users\HarmV> $string1,$string2 -join " "
C:\Users\HarmV> $string1="Good" C:\Users\HarmV> $string2="Evening" C:\Users\HarmV> $string1,$string2 -join " " Good Evening

C:\Users\HarmV> $string1="Good"
C:\Users\HarmV> $string2="Evening"
C:\Users\HarmV> $string1,$string2 -join " "
Good Evening

But you can also split a string using -split using the ";" character as a delimiter, for example:

C:\Users\HarmV> $string="Hello;world"
C:\Users\HarmV> $string -split ";"
C:\Users\HarmV> $string="Hello;world" C:\Users\HarmV> $string -split ";" Hello world
C:\Users\HarmV> $string="Hello;world"
C:\Users\HarmV> $string -split ";"
Hello
world
This will output the string in two lines. You can combine those again by using -join:

C:\Users\HarmV> $string -split ";" -join " "
C:\Users\HarmV> $string -split ";" -join " " Hello world
C:\Users\HarmV> $string -split ";" -join " "
Hello world

You can also select a certain range of characters from a string using SubString, for example:

C:\Users\HarmV> $string="Hello world"
C:\Users\HarmV> $string.SubString(0,5)
C:\Users\HarmV> $string="Hello world" C:\Users\HarmV> $string.SubString(0,5) Hello
C:\Users\HarmV> $string="Hello world"
C:\Users\HarmV> $string.SubString(0,5)
Hello

And you can search/replace words in a string using the replace method, for example:

C:\Users\HarmV> $string="Hello world"
C:\Users\HarmV> $string.Replace('Hello','Goodbye')
C:\Users\HarmV> $string="Hello world" C:\Users\HarmV> $string.Replace('Hello','Goodbye') Goodbye world
C:\Users\HarmV> $string="Hello world"
C:\Users\HarmV> $string.Replace('Hello','Goodbye')
Goodbye world
```
