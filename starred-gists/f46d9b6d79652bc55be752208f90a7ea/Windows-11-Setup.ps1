<#
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
iwr https://gist.githubusercontent.com/radtkedev/d8c4121931633eca04ca625d09ff1a11/raw/Windows-11-Setup.ps1 -OutFile C:\setup.ps1
& C:\setup.ps1
#>

if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process -FilePath "powershell.exe" -ArgumentList ("-File", $MyInvocation.MyCommand.Source, $args | %{ $_ }) -Verb RunAs; exit
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = "SilentlyContinue"

$ComputerName = "PC"
$SSHKeyFile = "id_ed25519"
$GitUsername = "radtkedev"
$GitEmail = "mail@radtke.dev"

if ( !(Get-ScheduledTask -TaskName "SetupScript" -ErrorAction SilentlyContinue ) ) {

Rename-Computer -NewName $ComputerName -Force | Out-Null

Set-Location "C:\"

Write-Output "Updating Windows Store Apps..."
Get-CimInstance -Namespace "root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod | Out-Null

Write-Output "Customizing start menu..."
if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")){
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
}
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")){
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
}

New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value "1" -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Value "1" -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "ShowOrHideMostUsedApps" -Value "0" -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Value "1" -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsMenu" -Value "1" -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value "0" -PropertyType Dword -Force | Out-Null

Write-Output "Remove pinned items from the start menu..."
Remove-Item "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState" -Recurse -Force -ErrorAction Ignore
New-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy" -Name "LocalState" -ItemType "directory" -Force | Out-Null
$HexString = "E27AE14B01FC4D1B9C00810BDE6E51854E5A5F47005BB1498A5C92AF9084F95E9BDB91E2EEDDD701300B000067DEFA31529529B3D32D8092A6EB66C8D5EADB19CF9B13518AAB93275D9CEEF37E62C3574C036F327D1110AB0977996D67A2F8FA897D7207BEE85586B8CE6AD4F9736AA2154E3DCC9D082996984B76F1C73067F124F92A41F2B2CA83EF35436670979556FAE85AB10EA16C932C3AECE1D45DA06D64BC42F4565AD0FCB8C63CDE7F6BB97ACE300198C3EACA3E1C974F547B1A7CF5B9C6A912448AB38A3BE2D6F0230A4A9AACC710C3E75088754CC2FB054B55B1D6ED7AD41EB8B0C9D4C274E87A525582F6CFBEAE5A904A1B0A3BA07939B79CAB4F1C3DF35BF88DE846E64555F0AEB47562C329206A9975664558849E0C251E8832D52B4FD7560347E5606AC882B9FC1F43C96922C0EA1927DF004A062BAD5AC5A4BE6BF2DB23158B2BAEEF8DE9E3A777910E82E5488A83E4D64B0D84440B98B35BC4A3438596145669904AB392CFD5F7E22F616747B84851481FE1FF41CA9A2534CCE7AFC45584370B4940DF30555536344249690F00C3A7E2552E352FE733C7ED2F80A29AD16937810AF805A444A344188C0CBDA51E5466BF45F2587508A69581CC2BCDAE06CB363658D94CD60569352FDA17AE7CDD785810F369B41F2D15930430A809567CC6C643FE7986CAD545EF3DB40CA6FA9220BFC7F65610AECB22799838B80DE73AF549923F8219FFAAD64780E2DB53133D73890294E77F9B0970484E86A050737724FF15281C1726D334D3C9A67A85A78AE33F55DB675DAA31C47A156C0F8212DCEE228537668F4BF898C0CB869B74C98DF7EFBE0130859E5156417A85CC634B86314FAB47FB9A8DFEAFA1AEFC5E599A3F744BA51E8E6823F80E1529187FA5A78420B1EC091FD93134A71A0A0F478341D9ABD2CEABD5444160023C9CAB0A5C2BAC97F55F1E98FD21F2CFF03D2D24E0C4642F4A8A6E7627BD143AFC1A6DAE697B286C941B5EAAF57D34D598317C97F7CA23544B219196661B73E9DD27EBFE204B43C98C241AB02D2AA3A4EE7B2B477FC5E31642AF613BF356DFBE8AD666CE93267A3D45FD40F83CABAA2F0AE2601C470D98AC4ABBCFA968882986297D06D81C1BE1EE8A0E64FB7543981B8E632809FBA7606BF518E8792EF4FBDC5CFC55690D8DF60812ECB2A39EB24B6F941C966DEF89E61E000D3F28CB6B260B17A53CE8EEFC371C98BBEE72DE915BA9023DC74EEE7895D60AC2D13B51E73EB37E0FB714BB259614F3F7CBECD66EBDAE52FCB01D778C413DE0ED739DEA7AE48543614B93D46F63D1076E3C7696863D8F64EAC7CAA7224FEB1A15E114358F379CA686AD7F09E75E2350F38A3B27F38D2DEFFB008B007371BD32E65B39FF6661DA237F277AC4A9C4DA5A1753250BBD3FA7ECD07E594C2014B5E26E06414B6588211CE439DAA2A352B017C196B4F20049DDBF2E4514E2CD7545E5AE22E877D5B6975D7FCDC61D49958258A093B05DB6D7C6457B9C260A420B1A15C6010B9C4AE68078E1B9592C97B47BFFE2C2F10A10129CC3B087041840091D2A6F5FDA1561E2F0315F8F0BF46204AA4E7C12DC819A1ABCDEB02400AA2FD46ECE2B8698C19F61ECA68232536A712BC858029D40FED5C20A051BCE6D316B03A97FE7051EE0C952A7EB9FD2F77D9FBE75022FF5D13B168BD0B004D9C803E8F8C5D8F25CB22ACC97D8EDE169E5D50FCD87444C2029F021D87807B4A04EF148EF1C814E2827FABBCDE9E042140E0D890CEDE88B21F9824956D8F18EF3A8AC85194248915F53AF26F70BC5FDC26E415936EAB0DD78398B725F5419E8DDFD46EE9A17A37087507F9D20358208A65366C4824518E75413FDE5F27FC5DD8132EFB4414A5BDDDA1D64593D86360062373FEE36F51ED56CA419FAD69751F76588995F9E2BE75ED13D2DED91EC1DED011752089716DD9C89DE21B8E52AD08CF1C463B0D79111200DF5269C646FBF0E3091A413CA70F6CA8F75BE257DB028329F7224023603C743AB204F8DAB5C273975FA93FBAAD84D0E4D72ABAC3A4E23D7236C848AD317E73E114C5B7438B8248C75B528E19E26D9BF908001A3214A137F24C74BC7D9910F858E47789FDFE52AB712AE758AE15C4D86ED3C23D4EB78C5ED94D8A5AB8AA93C43E18FC0CE418AC79DF945E81A58B70332A2C03C445436E8013E0B82AC59AF856C6A00812BCD3B6209449B6D008CA37D8A9210A61049350AD07F4E88FC7FBEC9FC64BC60C318912E36DBEA6D4058AF35CACD6E790C96B66EAE5966C47D3E1C4ACF42BF04D58FF363D20DBA61C9D32EBE433A45AFE02B41FD6FC91AE7157CCD7FACEC294623F825DE576F72A8245D2BC5D1D7C71B183166C8F0DAF9CF8ED6F1DAEBB0349D82E57BB81DB946128A5440235AD6222A294B27E97738D49F52170DE1B1B922C8C548215FD0D2980D7BA9B8F3133D9415BAB29670A5EDEC4858EB9D1A7E8FBD0296CB6D610BDD44A1A450EDEC61983152C237225F7AABABD482EB08328BC338D87BA1FE30864D9A97C20FA42CAEDF6359457C8BB26032A9728E819FFF9BF4F715469A0A4506A4CA1625E79CAE215683CDAADFB1E68ADC4987FF3FD7E9859CB40291478A4D2B281AEFEB97DC45C7F991311A68C2F173E2377709C355C6870DC4C14E5534120539C1DB0AD0D6E331D670581F6E352DCB3E34D61E6742F957FE9F39854A324E07C68A17BE9CB19446583EDDAAFD0E433A54F4E0854709BD47B24AC76DF75849B9D917FF2B0F4228C94EA01CF658430B2C18F6EEAB104B9A935C6FBFEA494190BF3446DCC8C8AAF62BA01F0BFB18E15503C27558DB70C48EFB0AEA0B600F985C904E9F244E2A08464AE980E1A8CC05F22C9D4C23D753FD5250D0E190CB0CAC71404CF52A8CCEC988DBA22F2164E203FB52064F38D8277764FECB0E2D811C307E4687CF6A245B2B89389D188E1F115EF2B36BA1BE63222A2C7E886A279B08ADF70109903F70EA1068137E72E894758614FE4BBAF333B8FC3EA98B149B3403FF8655FAAE1DF4877B5CDABC434B7336AB24C25A85246ADAA24DECB5A39F8FD7A5549F23F112244B7EE9E447D3226F2259428FDC0C3D6CD3A47B39092532B803FEBB6FFCC1ADF26C7857F04F294F16A9DA7DD851D4EC99BBCF853FD3435A256F47DD3CB9480365C2896A1D0E2314940968E4E3714723B4C1CDD368581FED307C8B279AE6FB8BB72EC0A093733E2D9CC6B43320766D3B43D3C554CA82EEEF7B09850D29B2F412DEF3D0BD9194CAE8113B3B38085C77C238CB8D15BF6D6AB42C193F4E2F27F8BEDABB2D6ADE9E486B6AFAFD8D5DBE3B7D7305790F96ECDCC2DD016C5B9B200CB72E6CF54D71F69A01CDE4E3A0A4C5A03627DECD491F215C1420EB07AB8FD2763FCFF5211EB964C82E69DA208BDFA76306D54642B117DCB9A92927CE2E633338D4EEA63B571349B8DA1D4B5523C4CA10308769E4F461ADD16DD5DFDB0E705187593DEF5CCCF659E48366462CC21D7930E1064234157A7A08E9C90927A37C5CF23D54C755002E4E657BB6E70D9B4BE7C468C19D6969FAE138EBF2C20DD3F5A0BC4C0E97D5BFDB8744A21396C44549242817BEAD5AE14FF602E69E75B87784DE5F30BE14106E8D8A081DC8CCCFBF93896E622F755F27E82A596DDCA3469A93ECB9E2E897BF0FCC063426DACDC3B1D81E1EFE6B639326CA43526CFAEDF9922EAC3204FEB84AAED781EE5516FA5B4DCAB85DB5FF33CEC454DAA375BDA5EEA7C871C310AEDC5BD6B220B59B901D377E22FFFE95FEDA28CE2CE33CAEB8541EE05E1B5650D776C4B2A246DB4613E2CC5D96A44D24AE662D848A7C9E3E922AFF0632B7B40505402956FABC5C3AAB55EEE29085046C127E8776CEFC1690B76EE99371AF9B1D7EF6F79E78325DD3BD8377E9B73B936C6F2611D0A1223A4D7C6CF3037922DD0686A701FF86761993F294D26E13A7BB8B1C61ACAF38D50334A88DABB3FA412B4FC79F6FBFD0D0A92301484FF1BD1CF3DC67780E4562E05CCA329CABA7CB2B77D9A707BDEE24B1E5E4ED6CC9D5A337908BE5303E477736C8A75051A8FBD4E3CB6360D8F0A992A48F333434D4AE712EC830BCB5EAA98788B6C76C"
$Bytes = [byte[]]::new($HexString.Length / 2)
For($i=0; $i -lt $HexString.Length; $i+=2){$Bytes[$i/2] = [convert]::ToByte($HexString.Substring($i, 2), 16)}
Set-Content "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start.bin" -Value $Bytes -Encoding Byte

Write-Output "Customizing Windows Explorer..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value "1" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0" -Force

Write-Output "Disable Edge Shortcut creation on the Desktop..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type Dword -Value "1" -Force

Write-Output "Disabling AutoRun..."
if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")){
    New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
}
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value "255" -Force | Out-Null

Write-Output "Disable autocorrection..."
if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Control Panel")){
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Control Panel" -Force | Out-Null
}
if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Control Panel\International")){
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Control Panel\International" -Force | Out-Null
}
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Control Panel\International" -Name "TurnOffAutocorrectMisspelleDwords" -Value "1" -PropertyType Dword -Force | Out-Null

Write-Output "Customizing the task bar..."
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force | Out-Null
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force | Out-Null
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force | Out-Null
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value "0" -PropertyType Dword -Force | Out-Null

#((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq "Microsoft Edge"}).Verbs() | ?{$_.Name.replace("&","") -match "Unpin from taskbar"} | %{$_.DoIt(); $exec = $true}
((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq "Microsoft Store"}).Verbs() | ?{$_.Name.replace("&","") -match "Unpin from taskbar"} | %{$_.DoIt(); $exec = $true}

Write-Host "Disabling Telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type Dword -Value "0"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type Dword -Value "0"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type Dword -Value "0"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null

Write-Host "Disabling Application Suggestions..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type Dword -Value "0"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type Dword -Value "0"
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type Dword -Value "1"

Write-Host "Disabling Activity History..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type Dword -Value "0"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type Dword -Value "0"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type Dword -Value "0"

Write-Host "Disabling Location Tracking..."
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type Dword -Value "0"
if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service")){
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service" -Force | Out-Null
}
if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration")){
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type Dword -Value "0"

Write-Host "Disabling Automatic Map Updates..."
Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type Dword -Value "0"

Write-Host "Disabling Feedback..."
If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type Dword -Value "0"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type Dword -Value "1"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null

Write-Host "Disabling Tailored Experiences..."
If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type Dword -Value "1"

Write-Host "Disabling Advertising ID..."
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type Dword -Value "1"

Write-Host "Disabling Error reporting..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type Dword -Value "1"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null

Write-Host "Stopping and disabling Diagnostics Tracking Service..."
Stop-Service "DiagTrack" -WarningAction SilentlyContinue
Set-Service "DiagTrack" -StartupType Disabled

Write-Host "Stopping and disabling WAP Push Service..."
Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
Set-Service "dmwappushservice" -StartupType Disabled

Write-Host "Disabling Remote Assistance..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type Dword -Value "0"

Write-Host "Stopping and disabling Superfetch service..."
Stop-Service "SysMain" -WarningAction SilentlyContinue
Set-Service "SysMain" -StartupType Disabled

Write-Host "Showing task manager details..."
$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
Do {
    Start-Sleep -Milliseconds 100
    $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
} Until ($preferences)
Stop-Process $taskmgr
$preferences.Preferences[28] = 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences

Write-Host "Enabling NumLock after startup..."
If (!(Test-Path "HKU:")) {
    New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
}
Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type Dword -Value "2147483650"
Add-Type -AssemblyName System.Windows.Forms
If (!([System.Windows.Forms.Control]::IsKeyLocked("NumLock"))) {
    $wsh = New-Object -ComObject WScript.Shell
    $wsh.SendKeys("{NUMLOCK}")
}

Write-Host "Removing AutoLogger file and restricting directory..."
$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
    Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
}
icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

Write-Host "Disabling Lock Screen..."
If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization")) {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type Dword -Value "1" | Out-Null

Write-Output "Disabling Advertising ID..."
If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type Dword -Value "0"

Write-Output "Disabling SmartScreen..."
if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer")){
    New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "Off"
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost")){
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value "0"

Write-Output "Disabling File History..."
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileHistory")){
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileHistory" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileHistory" -Name "Disabled" -Type Dword -Value "1"

Write-Output "Disable Hand Writing Reports..."
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports")){
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" -Name "PreventHandwritingErrorReports" -Type Dword -Value "1"

Write-Output "Disabling Location Tracking..."
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors")){
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type Dword -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Type Dword -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableSensors" -Type Dword -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableWindowsLocationProvider" -Type Dword -Value "1"

Write-Output "Disabling Auto Map Downloading/Updating..."
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps")){
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name "AutoDownloadAndUpdateMapData" -Type Dword -Value "0"
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings")){
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Force | Out-Null
}
Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -ErrorAction SilentlyContinue | ForEach-Object {
    Set-ItemProperty -Path $_.PsPath -Name "Enabled" -Type Dword -Value "0"
    Set-ItemProperty -Path $_.PsPath -Name "LastNotificationAddedTime" -Type Qword -Value "0"
}

Write-Output "Disabling Keyboard annoyances..."
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value "122"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "58"

Write-Output "Disabling Delivery Optimization..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc" -Name Start -Value 4

Write-Output "Set Alt-Tab view without last Edge windows"
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "MultiTaskingAltTabFilter" -Type Dword -Value "4"

Write-Output "Disable SnapAssist..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Type Dword -Value "0"

Write-Output "Remove all desktop shortcuts..."
Remove-Item -Path "C:\Users\*\Desktop\*.lnk" -Force -ErrorAction Ignore
Remove-Item -Path "C:\Users\Public\Desktop\*.lnk" -Force -ErrorAction Ignore

Write-Output "Installing winget..."

Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle -UseBasicParsing
Add-AppPackage -Path "winget.msixbundle" -ErrorAction Ignore

Write-Output "Installing winget packages..."
$InstallPackages = @(
    "7zip.7zip"
    "Balena.Etcher"
    "dbeaver.dbeaver"
    "Docker.DockerDesktop"
    "HexChat.HexChat"
    "Microsoft.Office"
    "Microsoft.Teams"
    "Microsoft.VisualStudioCode"
    "Microsoft.WindowsTerminal"
    "RoyalApps.RoyalTS"
    "Rufus.Rufus"
    "SparkLabs.Viscosity"
    "Telegram.TelegramDesktop"
    "VMware.HorizonClient"
    "VideoLAN.VLC"
    "WinSCP.WinSCP"
)
foreach ($Package in $InstallPackages) {
  winget install -e --id $Package --accept-source-agreements --accept-package-agreements
}

Write-Output "Uninstalling unnecessary packages..."
$UninstallPackages = @(
  "Microsoft.BingNews"
  "Microsoft.BingWeather"
  "Microsoft.MicrosoftOfficeHub"
  "Microsoft.MicrosoftSolitaireCollection"
  "microsoft.windowscommunicationsapps"
  "Microsoft.WindowsFeedbackHub"
  "Microsoft.WindowsFeedbackHub"
  "Microsoft.WindowsMaps"
  "Microsoft.YourPhone"
  "Microsoft.ZuneMusic"
  "Microsoft.ZuneVideo"
  "MicrosoftTeams"
)
foreach ($Package in $UninstallPackages) {
  Write-Output "Uninstalling $Package..."
  Get-AppxPackage -AllUsers | Where-Object Name -like $Package | Remove-AppxPackage -ErrorAction SilentlyContinue
  Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Package | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Output "Disable Windows Media Player..."
Disable-WindowsOptionalFeature -NoRestart -Online -FeatureName "WindowsMediaPlayer" | Out-Null

Write-Output "Disable XPS Document Writer..."
Disable-WindowsOptionalFeature -NoRestart -Online -FeatureName "Printing-XPSServices-Features" | Out-Null

Write-Output "Setting up VirtualMachinePlatform, WSL and Debian..."
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Out-Null
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName VirtualMachinePlatform | Out-Null

Write-Output "Setting up PowerShell profile..."
$PowerShellProfile = @"
function prompt {"[PowerShell] `$(Split-Path -Path `$pwd -Leaf) > "}
"@
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\Documents\WindowsPowerShell | Out-Null
$PowerShellProfile | Out-File $env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

Write-Output "Setting up Windows Terminal settings..."
$WindowsTerminalSettings = @"
{
    "actions": 
    [
        {
            "command": 
            {
                "action": "copy",
                "singleLine": false
            },
            "keys": "ctrl+c"
        },
        {
            "command": "paste",
            "keys": "ctrl+v"
        },
        {
            "command": "find",
            "keys": "ctrl+shift+f"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "auto",
                "splitMode": "duplicate"
            },
            "keys": "alt+shift+d"
        }
    ],
    "copyFormatting": "none",
    "copyOnSelect": false,
    "defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "launchMode": "maximized",
    "profiles": 
    {
        "defaults": 
        {
            "bellStyle": "none",
            "colorScheme": "One Half Dark",
            "cursorShape": "underscore",
            "opacity": 80,
            "useAcrylic": true
        },
        "list": 
        [
            {
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -nologo",
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell"
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "hidden": true,
                "name": "Command Prompt"
            },
            {
                "guid": "{58ad8b0c-3ef8-5f4d-bc6f-13e4c00f2530}",
                "hidden": false,
                "name": "Debian",
                "source": "Windows.Terminal.Wsl"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": true,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            }
        ]
    }
}
"@
$WindowsTerminalSettings | Out-File "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\setup.ps1"
$Trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "SetupScript" -Trigger $Trigger -Action $Action -RunLevel Highest –Force

Restart-Computer -Force
}

Invoke-WebRequest -Uri https://aka.ms/wsl-debian-gnulinux -OutFile Debian.appx
Add-AppxPackage Debian.appx
Debian install --root
Debian run apt update
Debian run apt upgrade -y
Debian run apt install -y htop psmisc imagick ansible git zip man curl net-tools keychain pwgen qrencode
Debian run git config --global init.defaultBranch "master"
Debian run git config --global user.name $GitUsername
Debian run git config --global user.email $GitEmail
Debian run mkdir -p /root/.ssh
Debian run chmod 700 /root/.ssh
$bashrc = @"
cat <<EOT > /root/.bashrc
HISTCONTROL=ignorespace
PS1=`"[Bash] \W > `"
alias pw=`" pwgen -s 64 | tr -d "\n" | clip.exe`"
alias qr=`" qrencode -t ANSI256`"
eval \`$(keychain --quiet --eval --agents ssh $SSHKeyFile)
EOT
"@
Debian run $bashrc

Write-Output "Cleaning up temporary startup task and files..."
Set-Location "C:\"
Remove-Item -Path C:\winget.msixbundle -Force
Remove-Item -Path "C:\setup.sh" -Force
Remove-Item -Path "C:\Debian.appx" -Force
Unregister-ScheduledTask -TaskName "SetupScript" -Confirm:$false

Write-Output "The script has finished. Complete the following steps:"
Write-Output "- Add the SSH key to /root/.ssh/id_ed25519 using the following command with ctrl+x to exit:"
Write-Output "  $ Debian run `"nano -t /root/.ssh/id_ed25519 && chmod 600 /root/.ssh/id_ed25519`""
Write-Output "- Setup Telegram, HexChat and Outlook"
Write-Output "- Setup any VPN access and remote access points"
Write-Output "- Add the Microsoft Account for syncing to Microsoft Edge and/or GitHub Account for Microsoft VS Code"

Read-Host