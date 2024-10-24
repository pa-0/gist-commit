#
#  This file contains functions for maintaining a directory of
#  user-installed application files in Windows, similar to the 
#  organization / methods that are used to maintain the
#  /opt directory in GNU/Linux and other UNIX-based systems.
#

# Downloads and extracts an archive of the current release
# of the application given in the function args to the
# following directory:
#
#  $APPSROOT\$APPNAME\$APPRELEASE
#    e.g. "A:\croc\9.5.4\"
function installAppRelease {
    
    # USAGE: 
    #   installAppRelease -app "croc" -release "9.5.4" -url "https://t.o/path/to/master.zip"
    
    param (
       [Parameter(Mandatory)]$Release,
       [Parameter(Mandatory)]$App,
       [Parameter(Mandatory)]$Url
    )
    $AppsRoot = "J:\apps.portable" 
    $ArchiveFileExt = Split-Path -Path $Url -Extension
 
    $AppBasePath = Join-Path -Path $AppsRoot -ChildPath $App
    $AppLatestPath = Join-Path -Path $AppBasePath -ChildPath $Release
 
    if (-Not (Test-Path -Path "$AppBasePath")) { 
        New-Item -Type Directory "$AppBasePath"
    }
    if (-Not (Test-Path -Path "$AppLatestPath")) { 
        New-Item -Type Directory "$AppLatestPath" 
    }
  
    $ArchiveFilename = "$App-$Release$ArchiveFileExt" 
    echo $ArchiveFilename
 
    $ExtractPath = "$AppLatestPath"
    echo $ExtractPath
 
    $DownloadedArchive = (Join-Path "$Env:TEMP" -ChildPath "$ArchiveFilename")   
    echo $DownloadedArchive
 
    Invoke-WebRequest -Uri "$Url" -OutFile "$DownloadedArchive"
  
    $ExtractShell = New-Object -ComObject Shell.Application 
    $ExtractFiles = $ExtractShell.Namespace($DownloadedArchive).Items() 
    $ExtractShell.NameSpace($ExtractPath).CopyHere($ExtractFiles) 

    return $ExtractPath
}

#
#  This function takes a newly downloaded app release from the
#  function above and then links the folder associated with the 
#  (1) app release and (2) app name given as arguments to this 
#  function to link to a special directory which always points
#  to the most recent version of app installed via this script.
#
#   $APPSROOT\$APPNAME\$APPRELEASE -> "$APPSROOT\$APPNAME\current"
#
function makecurrent() {
    
    # USAGE: 
    #   makeCurrent -app croc -release 9.5.4
    
    param (
       [Parameter(Mandatory)]$AppName,
       [Parameter(Mandatory)]$AppRelease
    )

    $AppsRoot = "J:\apps.portable" 
    $AppBasePath = Join-Path -Path $AppsRoot -ChildPath $AppNAme
    $AppLatestPath = Join-Path -Path $AppBasePath -ChildPath $AppRelease

    New-Item -Type Junction -Path $AppsRoot -Name current -Value $AppLatestPath
}