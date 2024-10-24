# Setup symlinks

$mappings = @(
  @{
    source = "$Env:USERPROFILE\.gitconfig"
    dest = "$PWD\Git\.gitconfig"
  },
  @{
    source = "$Env:LOCALAPPDATA\nvim\"
    dest = "$PWD\NeoVim\"
  },
  @{
    source = "$Env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\"
    dest = "$PWD\WindowsTerminal"
  },
  @{
    source = "$Env:LocalAppData\k9s\views.yml"
    dest = "$PWD\K9s\views.yml"
  },
  @{
    source = "$Env:USERPROFILE\.ideavimrc"
    dest = "$PWD\.ideavimrc"
  }
)

foreach ($mapping in $mappings) {
  Write-Output "Creating symlink for $($mapping.source) -> $($mapping.dest)"

  if (Test-Path -Path $mapping.source) {
    # Note: I've commented this line out for the blog post, as it's destructive, and I didn't want to risk someone blindly
    # using it and losing their config. Once your config is in Git, you can uncomment this line - but make sure you
    # knowing what you're doing!
    # $(Get-Item $mapping.source).Delete()
  }

  New-Item `
    -ItemType SymbolicLink `
    -Path $mapping.source -Target $mapping.dest
}

# Ensure Powershell profiles are just pointing here

# Just like above, I've also commented these lines out for this Gist because they're destructive commands, and I want
# to avoid someone blindy copying and pasting, and losing their Powershell profiles. They'll trash your Powershell profiles,
# and replace with just a reference to the profile in your Git repository. Only uncomment out if you know what you're doing!
# echo ". `"$PWD\Powershell\profile.ps1`"" > $Env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# echo ". `"$PWD\Powershell\profile.ps1`"" > $Env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1
