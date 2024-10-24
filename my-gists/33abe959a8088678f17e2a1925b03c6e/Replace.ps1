Explanation:

# Example 1: Extracts the file extension using [System.IO.Path]::GetExtension($path) and removes it from the file name using [System.IO.Path]::GetFileNameWithoutExtension($path).

# Example 2: Uses -replace '_.*', '' to remove everything after the first underscore in a string.

# Combined Example: Demonstrates both concepts together, extracting the file name without extension from a path and then cleaning it by removing everything after the first underscore.

# Example 1: Extracting and Removing the File Extension

# Given path
$path = "C:\Users\JohnDoe\Documents\Report.docx"

# Extract the file extension
$extension = [System.IO.Path]::GetExtension($path)

# Remove the file extension from the path
$filenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($path)

Write-Host "Given path: $path"
Write-Host "File extension: $extension"
Write-Host "File name without extension: $filenameWithoutExtension"
Write-Host

# Example 2: Using -replace to Clean Up a String

# Given string
$originalString = "Microsoft.LanguageExperiencePackhe-IL_8wekyb3d8bbwe"

# Remove everything after the first underscore
$cleanedString = $originalString -replace '_.*', ''

Write-Host "Given string: $originalString"
Write-Host "Cleaned string: $cleanedString"
Write-Host

# Combined Example: Extracting, Removing Extension, and Cleaning String

# Given path
$path = "C:\Users\JohnDoe\Documents\Report_8wekyb3d8bbwe.docx"

# Extract and remove the file extension
$filenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($path)

# Clean up the string by removing everything after the first underscore
$cleanedFilename = $filenameWithoutExtension -replace '_.*', ''

Write-Host "Given path: $path"
Write-Host "File name without extension: $filenameWithoutExtension"
Write-Host "Cleaned file name: $cleanedFilename"

# Key Points
# Flexibility: Split-Path -Leaf is versatile and can handle both full file paths and filenames.

# Regex Replacement: Using -replace '\.[^.]*$', '' ensures that only the extension is removed, preserving the rest of the filename.

# These examples illustrate how Split-Path -Leaf can be used effectively to manipulate filenames and paths in PowerShell. Adjust them based on your specific scenarios and requirements.


# Explanation
# Full File Path: With $path = "C:\Users\JohnDoe\Documents\Report.docx", Split-Path -Leaf $path returns "Report.docx", which is the filename with extension.

# Remove Extension: To remove the extension from $filename, we use -replace '\.[^.]*$', ''. This regex pattern ('\.[^.]*$') matches the last dot (\.) followed by any characters that are not dots ([^.]*) until the end of the string ($), effectively removing the extension.

# Result: $filenameWithoutExtension will contain "Report", which is the filename without the .docx extension.

# Removing Extension Using Split-Path -Leaf
# Example with full file path
$path = "C:\Users\JohnDoe\Documents\Report.docx"

# Get the filename using Split-Path -Leaf
$filename = Split-Path -Path $path -Leaf

# Remove the file extension
$filenameWithoutExtension = $filename -replace '\.[^.]*$', ''

Write-Host "Given path: $path"
Write-Host "Filename (using Split-Path -Leaf): $filename"
Write-Host "File name without extension: $filenameWithoutExtension"


# Using  Split-Path -Leaf with Filenames
# Even if you only have a filename (without a path), you can still use Split-Path -Leaf to handle it. PowerShell treats the filename as if it were a leaf in the current directory structure.

# Example with filename only
$filename = "Report.docx"

# Get the filename using Split-Path -Leaf (simulating a full path)
$leaf = Split-Path -Path $filename -Leaf

# Remove the file extension
$filenameWithoutExtension = $leaf -replace '\.[^.]*$', ''

Write-Host "Given filename: $filename"
Write-Host "Filename (using Split-Path -Leaf): $leaf"
Write-Host "File name without extension: $filenameWithoutExtension"
