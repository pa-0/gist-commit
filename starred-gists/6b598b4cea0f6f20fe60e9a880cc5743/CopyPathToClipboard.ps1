Set-PSReadlineKeyHandler -Key Ctrl+Shift+P `
    -BriefDescription CopyPathToClipboard `
    -LongDescription "Copies the current path to the clipboard" `
    -ScriptBlock { $pwd.Path.Trim() | clip }
