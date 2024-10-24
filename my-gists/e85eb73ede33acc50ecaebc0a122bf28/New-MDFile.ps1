function New-MDFile ($fileName) {
    $fileName+=".md"
    "" | Set-Content -Encoding Ascii $fileName
    Invoke-Item $fileName
}