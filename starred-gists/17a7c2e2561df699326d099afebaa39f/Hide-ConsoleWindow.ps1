# Adapted from https://stackoverflow.com/a/74976541/4087397
function Hide-ConsoleWindow() {
    # Import 'ShowWindowAsync' method to properly hide windows
    Add-Type -Name User32 -Namespace Win32 -MemberDefinition `
        '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    # Mangle the window title to ensure it's unique and allow us to find it
    $Host.UI.RawUI.WindowTitle = [Guid]::NewGuid()
    # Find our process by the mangled window title and hide it
    [Win32.User32]::ShowWindowAsync(
        (Get-Process).where{ $_.MainWindowTitle -eq $Host.UI.RawUI.WindowTitle }.MainWindowHandle, 0)
}