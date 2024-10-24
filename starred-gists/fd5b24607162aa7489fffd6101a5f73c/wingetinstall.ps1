# Fetch the URI of the latest version of the winget-cli from GitHub releases
$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith('.msixbundle') }

# Extract the name of the .msixbundle file from the URI
$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split('/')[-1]

# Show a progress message for the first download step
Write-Progress -Activity 'Installing Winget CLI' -Status 'Downloading Step 1 of 2'

# Temporarily set the ProgressPreference variable to SilentlyContinue to suppress progress bars
Set-Variable ProgressPreference SilentlyContinue

Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml -OutFile .\microsoft.ui.xaml.nupkg.zip
Expand-Archive -Path .\microsoft.ui.xaml.nupkg.zip -Force

# Get the .appx file in the directory
$appxFile = Get-ChildItem -Path .\microsoft.ui.xaml.nupkg\tools\AppX\x64\Release -Filter "*.appx" | Select-Object -First 1

# Install the .appx file
Try { Add-AppxPackage -Path $appxFile.FullName -ErrorAction Stop } Catch {}

# Download the latest .msixbundle file of winget-cli from GitHub releases
Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"

# Reset the ProgressPreference variable to Continue to allow progress bars
Set-Variable ProgressPreference Continue

# Show a progress message for the second download step
Write-Progress -Activity 'Installing Winget CLI' -Status 'Downloading Step 2 of 2'

Set-Variable ProgressPreference SilentlyContinue

# Download the VCLibs .appx package from Microsoft
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx

# Try to install the VCLibs .appx package, suppressing any error messages
Try { Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction Stop } Catch {}

# Install the latest .msixbundle file of winget-cli
Try { Add-AppxPackage $latestWingetMsixBundle -ErrorAction Stop} Catch {}
Write-Progress -Activity 'Installing Winget CLI' -Status 'Install Complete' -Completed
Set-Variable ProgressPreference Continue