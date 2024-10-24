<#
.SYNOPSIS
Verifies that the file hash of a PowerShell open-source installer matches expected value.

.DESCRIPTION
Compares the file hash of a PowerShell open-source installation file to the expected file hash value. Supports
all installation file types, including msi, zip, rpm, deb, pkg, and tar.gz, beginning with installers for PowerShell
release 6.0.0.9.

To get a list of installer file names, but not test the file hash, use the ListOnly parameter.		
To verify the file hash, enter the path and name of the installer file. Test-PSFileHash returns a Boolean value. 

.PARAMETER Path
Enter the path and file name of the installer file. If you omit the path, the default is the local directory.

.PARAMETER ListOnly
Returns only the names of installer files for which this script stores file hashes.

.OUTPUTS
string, boolean

.EXAMPLE
Test-PSFileHash -ListOnly
powershell-6.0.0_alpha.11-1.el7.centos.x86_64.rpm
powershell_6.0.0-alpha.11-1ubuntu1.14.04.1_amd64.deb
powershell_6.0.0-alpha.11-1ubuntu1.16.04.1_amd64.deb
powershell-6.0.0-alpha.11.pkg
...

.EXAMPLE
Test-PSFileHash -Path $HOME\Downloads\PowerShell_6.0.0.11-alpha.11-win10-x64.msi
True

.NOTES
===========================================================================
Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.129
Created on:   	10/24/2016 4:00 PM
Updated on:     11/07/2016 9:17 AM
Created by:   	June Blender
Organization: 	SAPIEN Technologies, Inc
Filename:       Test-PSFileHash.ps1
===========================================================================
#>
[CmdletBinding(DefaultParameterSetName = 'StandardSet')]
[OutputType([string], ParameterSetName = 'ListOnly')]
[OutputType([boolean], ParameterSetName = 'StandardSet')]
param
(
	[Parameter(ParameterSetName = 'StandardSet',
			   Mandatory = $false)]
	[ValidateScript({Test-Path $_})]
	[string]
	$Path,
	
	[Parameter(ParameterSetName = 'ListOnly')]
	[switch]
	$ListOnly
)

$Hashes = [ordered]@{
	'powershell-6.0.0-alpha.14.pkg' = '8fd7abc4ec1a2e4a28543b90a6ee60cd437d4b366b544c39b341a05276eb8ccf'
	'powershell-6.0.0_alpha.14-1.el7.centos.x86_64.rpm' = '88e01ff76d89b8ed16468bbc8ef8fa51ecb4bb341adb878eec139319411e2da0'
	'powershell_6.0.0-alpha.14-1ubuntu1.14.04.1_amd64.deb' = '402c3b6b51210b7e7700260cd5ea37f75ef56b97e4102a7ba62d431cb9879483'
	'powershell_6.0.0-alpha.14-1ubuntu1.16.04.1_amd64.deb' = 'b5a177fda872d5af05b029b7b1071ab37b192323170e10d853ac250e69ff95da'
	'powershell-6.0.0-alpha.14-win10-x64.zip' = '3F5FD873B6E3062D9741B019BC645E6F20999BE66B2FDAA4374495FEBEDD0E03'
	'powershell-6.0.0-alpha.14-win7-x64.zip' = '689E59C8A97A7F6F136104A56BE397D9456D46069AA2C1121BBDA421C14852F8'
	'powershell-6.0.0-alpha.14-win7-x86.zip' = 'DCB821299D8269989D8DCEAB5A45B4E7F959257CA5E640373C0675758C734505'
	'powershell-6.0.0-alpha.14-win81-x64.zip' = 'F5410AA6BAC63C53B5DE5882591F11CED2772DEA5C4AD728C9F9BFDC1A5B4142'
	'PowerShell_6.0.0.14-alpha.14-win10-x64.msi' = '503F3AD52223699765895D3E9615FBD7988194693BCB725BE90C9EF0CD594447'
	'PowerShell_6.0.0.14-alpha.14-win7-x64.msi' = '19A94B7533A5A2292E5E8BFFAB0143AEF31867A531447EAADCAAE714121E541A'
	'PowerShell_6.0.0.14-alpha.14-win7-x86.msi' = '3763A0D4E5859B16495CDA68279614E70A36FF51EA82148F302A54AC0D62E116'
	'PowerShell_6.0.0.14-alpha.14-win81-x64.msi' = '9BAF5D38719C28AE98A76683647AB9161A3A151A399781C050D43942D37C096C'
	'powershell-6.0.0-alpha.13.pkg' = '3bcb890d934a41fab1cb67e40e8ed6d58df902cddb420b4e359aa12ce7c85b01'
	'powershell-6.0.0_alpha.13-1.el7.centos.x86_64.rpm' = '290cac313a08a0118c34bff866f484fb7c7951b95c7461d439918f15663e5d71'
	'powershell_6.0.0-alpha.13-1ubuntu1.14.04.1_amd64.deb' = 'bc0890d45bdacd55ab82bc9b9e5951b22ee7955c67f78da43b862141338e50f7'
	'powershell_6.0.0-alpha.13-1ubuntu1.16.04.1_amd64.deb' = '719fc2d42486f4fe123156e9b4380929c6dd28cb6ccbf928ba746020c1caea58'
	'PowerShell_6.0.0.13-alpha.13-win10-x64.msi' = '1085c8fae76a9e8984c42a58740b71cf456b48495747453c0ae3a86fb4f1bf2a'
	'PowerShell_6.0.0.13-alpha.13-win7-x64.msi' = '48294e9e68169576d74836621fb68d0e2b615d4d7cd30523924ebdc78ad0cdc1'
	'PowerShell_6.0.0.13-alpha.13-win7-x86.msi' = '95aadecb26ac7d25659cda8960313a25152d9a0d618fae6979922d7ee27b479e'
	'PowerShell_6.0.0.13-alpha.13-win81-x64.msi' = '486c2494e382a70bf4559a4a56655e352dc34abe83fe02646849b43961f745be'
	'powershell-6.0.0-alpha.13-win10-x64.zip' = 'b54afedaec636d44e5c3dea0a8f4ee9d82d9e02eabff3eff1ce3d31010f83860'
	'powershell-6.0.0-alpha.13-win7-x64.zip' = '1a64f92533ef50ee412390c0c88aaa4c0e570fe8be7304596901915863747133'
	'powershell-6.0.0-alpha.13-win7-x86.zip' = '9dc162742e092ff32b23933463349f613c4b9f70055e4f86b7a61592f2829dd8'
	'powershell-6.0.0-alpha.13-win81-x64.zip' = 'a50c5ab93511e42e561cac8446cc30cb1e66aa5001d92e0dedf1983a76b0e03f'
	'powershell-6.0.0-alpha.12.pkg' = 'f990ba234d7fe0e017d53bc77382b28b7811f9e69f31a6ea1c13f97a69b67cdc'
	'powershell-6.0.0_alpha.12-1.el7.centos.x86_64.rpm' = '8104df5fa40e678d691a6a943988f9a5a864be08f60309b451970ae295de87ce'
	'powershell_6.0.0-alpha.12-1ubuntu1.14.04.1_amd64.deb' = '7e032d36b3e1e4d2e99fd0941d71ed3f08435fc0ecaa9f28b35531cff97c25ee'
	'powershell_6.0.0-alpha.12-1ubuntu1.16.04.1_amd64.deb' = '20acf9ee52966a5c43a3a7a8371ac3464f3270807835b68e4c5fd42d789449c8'
	'powershell-6.0.0-alpha.12-win10-x64.zip' = '257D5F081C112713DF17F6D0E4CBC794E5099664EDA8DBC543B996915834D5CE'
	'powershell-6.0.0-alpha.12-win81-x64.zip' = '0E91D255D419806A7D8F39D95158AFAD5A131944D137009F29327C32E310B8B0'
	'PowerShell_6.0.0.12-alpha.12-win10-x64.msi' = 'F3C3F3276462588E24BFE197DAA8795140E37557596861126D54462561C98671'
	'PowerShell_6.0.0.12-alpha.12-win81-x64.msi' = '5FEB757346D5ED6FA6786ACDA96D0361663EE4DCBB719D53E6C32835BFD8C670'
	'powershell-6.0.0_alpha.11-1.el7.centos.x86_64.rpm' = '6abd338de3d0d3b4ce060ba71aa9911b679e825f3e2af4a450685b6c45501a4b'
	'powershell_6.0.0-alpha.11-1ubuntu1.14.04.1_amd64.deb' = 'd6a30c17abdb600bd9c7c1dfdc00fe543c2a0572884757149027b8da7e199d25'
	'powershell_6.0.0-alpha.11-1ubuntu1.16.04.1_amd64.deb' = '57269171eeae0c15c09e72b662ea6caeba97e29ba8f22f6df568e18679e40a08'
	'powershell-6.0.0-alpha.11.pkg' = 'fdbc1f8545e89514da5e74e0fb3bdf1df9267ac9c0a020e6a71d3c506ddd6082'
	'powershell-6.0.0-alpha.11-win10-x64.zip' = 'b41504ee24b27fb7bcbc6b495dc380d5a8a61bd0490c5920d79b90dca5dfcde5'
	'powershell-6.0.0-alpha.11-win81-x64.zip' = '85fc7dc42a1ea1957199697644e93e25dd3b2b1ce2b55df3fee96e8ecd10dbf2'
	'PowerShell_6.0.0.11-alpha.11-win10-x64.msi' = 'ad15b3a3d7eccc2c604c51b5b2262e486ee05b55c532b9bf230a8f216db9f2b3'
	'PowerShell_6.0.0.11-alpha.11-win81-x64.msi' = 'afe230d5aaf19d39ecb33a47a80e5a627adae628c9aaad1ceb79b351ad7f5b0d'
	'powershell-6.0.0_alpha.10-1.el7.centos.x86_64.rpm' = 'c2756cdeec2e178aa8f5149fad6c0a115fc1fbf8f04d95d3545b953a3016c34c'
	'powershell_6.0.0-alpha.10-1ubuntu1.14.04.1_amd64.deb' ='41657975e0d16c3699eb0006794ed6ccfd891d0887b36a391df5f9d21a777f95'
	'powershell_6.0.0-alpha.10-1ubuntu1.16.04.1_amd64.deb' = '5a884a3c03ca4c7309231431b663c44fbc9125665560cbeb0ba811e296569b33'
	'powershell-6.0.0-alpha.10.pkg' = '01a2b1ea27b3ee03ebd92e10d5106f0a6df912e1d5586feeb4a8b57faba11c00'
	'PowerShell_6.0.0.10-alpha.10-win10-x64.msi' = 'f669482aeab8de04f4da5ac03a36ce6b4e9f6569401b4cc842a4cd59196756a0'
	'powershell-6.0.0-alpha.10-win10-x64.zip' = 'f394b51b6c8a865c0a1dd0c3645bb354e65339862ea95b60c9ff0226a307ded6'
	'PowerShell_6.0.0.10-alpha.10-win81-x64.msi' = '74b570442072000d40ad945ea8dbe4eec7cef8b0ac9d31e1da0457352b26d03d'
	'powershell-6.0.0-alpha.10-win81-x64.zip' = '2f4fd0b7a7a6447af724acdc0a42acec455e3ae916b7fed4895084faf71ae4aa'
	'v6.0.0-alpha.10.zip' = '6a928f525613fcf394f2a80faef3569b8e49cdcd97ebede50175b229d2a0a6d0'
	'v6.0.0-alpha.10.tar.gz' = '58b4c25333b8291b62b4d5a183725ab7a3ed6030c9f90a13a0c7acebe92b4fe7'
	'powershell_6.0.0-alpha.9-1ubuntu1.14.04.1_amd64.deb' = '275127929dcc36d5ef5c6d4a98784f65e50acae4fa9ce2f92e78220ac32983cc'
	'powershell_6.0.0-alpha.9-1ubuntu1.16.04.1_amd64.deb' = '5d56a0419c23ce879dd4ddaca009f03e888355fccc9eecf882b64d63da5f38e3'
	'PowerShell_6.0.0.9-alpha.9-win10-x64.msi' = '183892e908bac570e2018b5ad3e5eac440a3f38c6bde649719ebfa4b9d25e81d'
	'PowerShell_6.0.0.9-alpha.9-win81-x64.msi' = '83f88b20220a2d5d645cf4e42d866471c936e952bc9875eca7e8f353bb9bad31'
	'powershell-6.0.0_alpha.9-1.el7.centos.x86_64.rpm' = '7e891ca77c19b268d27fbc41f9fae19b21c76b2fcab0937347c8f812483f61e3'
	'powershell-6.0.0-alpha.9-win10-x64.zip' = '35b08c1b3482a5b613926bb8cb51c95591648381431117d74ff20e5d6beaf3d6'
	'powershell-6.0.0-alpha.9-win81-x64.zip' = '4c801f001ecea8a9bc95b02709144a1b27cb89d77242ae63e152b3e98aea7f86'
	'powershell-6.0.0-alpha.9.pkg' = 'de1f9ea55405efc681d845b1209e13f3057567841541822b60704d383c959574'
	'v6.0.0-alpha.9.tar.gz' = '11ee29caf4c1a362e0e2991da4f4b2b47860cfa4f199b34b643e151a6aeb29c0'
	'v6.0.0-alpha.9.zip' = '60120889bd0eefd81b82a96429854dd35f6c88959773d2a3cbc15fdcaeaa6e74'
}


<#
.SYNOPSIS
Gets a SHA-256 hash for the path in script $Path parameter.

.DESCRIPTION
This is a helper function that substitutes for Get-FilePath in versions
of Microsoft.PowerShell.Utility that don't yet have the function.

It doesn't have the features of Get-FileHash, like support for multiple
algorithms, so use it only when necessary.

#>
function Get-FileHashAlternative
{
	try
	{
		$hasher = [System.Security.Cryptography.SHA256CryptoServiceProvider]::New()
		[System.IO.Stream]$stream = [System.IO.File]::OpenRead($script:Path)
		[Byte[]]$computedHash = $Hasher.ComputeHash($Stream)
		[string]$hash = [BitConverter]::ToString($computedHash) -replace '-', ''
	}
	catch
	{
		Write-Error "Cannot compute file hash for $Path"
	}
	
	return $hash
}

# For mocking
function Test-GetFileHash
{
	#Test-Path Function:\Get-FileHash
	[System.Boolean](Get-Command Get-FileHash -ErrorAction SilentlyContinue)
}

if ($ListOnly)
{
	return $Hashes.Keys
}
elseif ($Path)
{
	$FileName = (Get-ChildItem $Path).Name
	if ($Hashes.Keys -notcontains $FileName)
	{
		Write-Error 'Cannot find expected hash for this file. To get a list of eligible files, run Test-PSFileHash -ListOnly.'
	}
	else
	{
		$expectedHash = $Hashes[$FileName]
		
		if (Test-GetFileHash)
		{
			Write-Verbose "Using Get-FileHash function"
			return (Get-FileHash -Path $Path).Hash -eq $expectedHash			
		}
		else
		{
			Write-Verbose "Using Get-FileHashAlternative"
			return (Get-FileHashAlternative) -eq $expectedHash
		}
	}
}