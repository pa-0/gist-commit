#region Rotate log file every 30 days
if (Test-Path -Path $LogPath) {
    if ((Get-Item -Path $LogPath -ErrorAction SilentlyContinue).CreationTime -le (Get-Date).AddDays(-30)) {
        $LogsDirectory = [System.IO.Path]::GetDirectoryName($LogPath)
        $FileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($LogPath)
        $FileExtension = [System.IO.Path]::GetExtension($LogPath)
        $BackupFilePath = Join-Path $LogsDirectory -ChildPath "${FileNameWithoutExtension}.bak${FileExtension}"
        Remove-Item -Path $BackupFilePath -Force -ErrorAction SilentlyContinue
        Move-Item -Path $LogPath -Destination $BackupFilePath -Force -ErrorAction SilentlyContinue
        # Due to file system tunneling, when a new file is created with the name of a previously deleted file, that new file will need to have it's creation date updated.
        # This is because file system tunneling sets the creation date, for the newly created file, to that of the previously deleted file.
        # The apocryphal history of file system tunnelling, https://devblogs.microsoft.com/oldnewthing/20050715-14/?p=34923
        New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
        (Get-Item -Path $LogPath).CreationTime = (Get-Item -Path $LogPath).LastWriteTime
    }
}
else {
    New-Item -Path $LogPath -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
}
#endregion