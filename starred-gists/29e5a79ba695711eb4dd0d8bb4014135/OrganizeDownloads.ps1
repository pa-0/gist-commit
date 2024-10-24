# Set the path to the Downloads folder
$downloadsPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads')

# Get all files in the Downloads folder
$files = Get-ChildItem -Path $downloadsPath

# Iterate through each file
foreach ($file in $files) {
    # Skip directories
    if ($file.PSIsContainer) {
        continue
    }

    # Get file extension
    $extension = $file.Extension.TrimStart('.')

    # Create folder for the extension if it doesn't exist
    $extensionFolder = [System.IO.Path]::Combine($downloadsPath, $extension)
    if (-not (Test-Path $extensionFolder -PathType Container)) {
        New-Item -ItemType Directory -Path $extensionFolder | Out-Null
    }

    # Create unique filename if file already exists in the destination folder
    $destinationPath = [System.IO.Path]::Combine($extensionFolder, $file.Name)
    $count = 1
    while (Test-Path $destinationPath) {
        $newFileName = "{0} ({1}){2}" -f $file.BaseName, $count, $file.Extension
        $destinationPath = [System.IO.Path]::Combine($extensionFolder, $newFileName)
        $count++
    }

    # Move the file to the destination folder
    Move-Item -Path $file.FullName -Destination $destinationPath -Force
}
