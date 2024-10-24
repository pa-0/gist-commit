# Execute this PowerShell from inside your directory.

# Adjust the pattern based on your needs. Don't include the extension
# Filename for this pattern : Replay_2023-12-01_21-04-14.mp4
$pattern = "Replay_(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})_(?<hour>\d{2})-(?<minute>\d{2})-(?<second>\d{2})"

Get-ChildItem -Filter "*.mp4" | % {
  if ($_.Basename -match $pattern) {
    $Matches.Remove(0)
    $filedate = Get-Date @Matches
    $dateString = $filedate.ToString("yyyy-MM-dd")
    $TargetPath = if (-not (Test-Path $dateString)) { 
      New-Item -ItemType Directory -Name $dateString
    } else {
      Get-Item $dateString 
    }
  Move-Item -Path $_ -Destination $dateString
  }
}