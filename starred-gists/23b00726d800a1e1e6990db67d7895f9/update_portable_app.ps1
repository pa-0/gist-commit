#    AppUpdate.ps1
#    -------------
#    @kriipke 2B22-02
#
#    Args:
#  
#   	1. URL  
#   	2. VERSION  
#   	3. URL 
#   	4. (APPS DIREECTORY)
#
#
#    Result: 
#
#    	Downloads the most current version of the app given to
#    	S:\opt or wherever $APPS_ROOT_D is set to
#  


function Get-LatestPortableApp {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Release,

        [Parameter(Mandatory)]
        [string]$GithubRepository
    )

$TargetRelease = 

$fso = new-object -comobject wscripting.fielsystemobject
$CFWIN_DRIVE = "$($fso.Drives | Where-Object -Property volumename -EQ 'Citrix Files').Path"

$APP_NAME = "dual-key-remap"

$APPS_ROOT_D = Join-Path -Path $CFWIN_DRIVE -ChildPath @("Personal Folders", "opt")


$TARGET_RELEASE = $Release
$TARGET_REPOSITORY = $GithubRepository


$APP_RELEASE_STR = "$APP_NAME-v$TARGET_RELEASE"
# this is like \apps\spotify
$APP_PARENT_DIR = Join-Path -Path $APPS_ROOT_D -ChildPath @($APP_NAME)
# this is like \apps\spotify\0.1
$APP_RELEASE_PATH = Join-Path -Path $APP_PARENT_DIR -ChildPath @($APP_RELEASE_STR)

$ARCHIVE_SRC_PATH = @(
	"https://github.com", 
	"$TARGET_REPOSITORY/releases/download/v$TARGET_RELEASE",
	"$APP_NAME-v$TARGET_RELEASE.zip"
) -join '/'

$ARCHIVE_DST_PATH = @(
	"$env:TEMP",
	"$APP_NAME-v$TARGET_RELEASE.zip"
)

echo "`n`t[DOWNLOADING]`n"
echo "`t from URL: $ARCHIVE_SRC_PATH"
echo "`t   to DIR: $ARCHIVE_DST_PATH"

$DownloadRequest = Invoke-WebRequest -Uri $ARCHIVE_SRC_PATH -OutFile "$ARCHIVE_DST_PATH"
return $DownloadRequest
$DownloadRequest | select-object -property Status,Description
}

Download-PortableApp -Release '0.6' -GithubRepository 'ililim/dual-key-remap'
exit 0



if($?)
{
if( $fso.FolderExists($INSTALL_DIR) )
{
    $errorMsg = "`nFolder where this arhive is being extracted already exists:`n`t$INSTALL_DIR`n"
    Get-ChildItem -Path $INSTALL_DIR -recurse   

    $decision = $Host.UI.PromptForChoice($errorMsg, 'Are you sure you want to proceed?', @('&Yes'; '&No'), 1)
	if($decision)
	{
		Expand-Archive -Path $ARCHIVE_DST_PATH -DestinationPath $INSTALL_DIR  -Verbose -Force
	}
		

}
else
{
    Write-Host "Folder Doesn't Exists"
    $fso.CreateFolder((Join-Path -Path $INSTALL_DIR -ChildPath $($ARCHIVE_DST_PATH))) 
    
    echo HERE WE GO
    #PowerShell Create directory if not exists
    New-Item $INSTALL_DIR -ItemType Directory
}
Expand-Archive -Path $ARCHIVE_DST_PATH -DestinationPath $INSTALL_DIR  -Verbose
echo "`bComplete!`n":
}
	

#function Download-PortableApp {
#
#    [CmdletBinding()]
#    param (
#        [Parameter(Mandatory)]
#        [string]$TargetRelease
#
#        [ValidateNotNullOrEmpty()]
#        [string]$APPS_ROOT_D = $env:COMPUTERNAME
#    )
#
#    Write-Output $TargetRelease
#
#}





#$Object = New-Object PSObject -Property ([ordered]@{ 
#
#ServerName              = $Server
#URL                     = $url
#Status                  = $HttpQuery.statusdescription
#StatusCode              = $HttpQuery.statuscode
#Content                 = $HttpQuery.content
# 
#})