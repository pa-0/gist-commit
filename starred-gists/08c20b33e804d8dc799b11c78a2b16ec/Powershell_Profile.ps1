# 配置 PowerShell 可下载安装互联网上的模块
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# oh-my-posh 是一个 Powershell 的主题项目，并设置主题为 gmay
Import-Module oh-my-posh
Set-PoshPrompt -Theme chester

# 显示文件类型图标的 Powershell 模块，基于 nerd-fonts
Import-Module -Name Terminal-Icons

# 清理控制台
Clear-Host

#region AutoCompleter

# 自动完成 dotnet 命令
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# 自动完成 npm 命令
Register-ArgumentCompleter -Native -CommandName npm -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $Local:ast = $commandAst.ToString().Replace(' ', '')
    if ($Local:ast -eq 'npm') {
        $command = 'run install start'
        $array = $command.Split(' ')
        $array | 
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_
        }
    }
    if ($Local:ast -eq 'npmrun') {
        $scripts = (Get-Content .\package.json | ConvertFrom-Json).scripts
        $scripts |
        Get-Member -MemberType NoteProperty |
        Where-Object { $_.Name -like "$wordToComplete*" } |
        ForEach-Object {
            New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_.Name
        }
    }
}

#endregion AutoCompleter

# 提供命令提示和补全功能
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle None

#region 自定义快捷键

# 删除当前字符
Set-PSReadLineKeyHandler -Chord Ctrl+d -Function DeleteChar
# 选中并复制整行/多行命令
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function CaptureScreen
# 删除下一个单词
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
# 删除前一个单词
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function ShellBackwardKillWord
# 向前移动一个单词
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
# 向后移动一个单词
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
# 选择前一个单词
Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
# 选择后一个单词
Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord

# 智能输入成对的 "", ''
Set-PSReadlineKeyHandler -Key '"', "'" `
    -BriefDescription SmartInsertQuote `
    -LongDescription “Insert paired quotes if not already on a quote” `
    -ScriptBlock {

    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    $keyChar = $key.KeyChar
    if ($key.Key -eq 'Oem7') {
        if ($key.Modifiers -eq 'Control') {
            $keyChar = "`'"
        }
        elseif ($key.Modifiers -eq 'Shift', 'Control') {
            $keyChar = '"'
        }
    }
    
    if ($line[$cursor] -eq $key.KeyChar) {
        # Just move the cursor
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        # Insert matching quotes, move cursor to be in between the quotes
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$keyChar" * 2)
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
    }
}

# 只能输入成对括号
Set-PSReadLineKeyHandler -Key '(', '{', '['`
    -BriefDescription InsertPairedBraces `
    -LongDescription "Insert matching braces" `
    -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar) {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    if ($selectionStart -ne -1) {
        # Text is selected, wrap it in brackets
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else {
        # No text is selected, insert a pair
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
}

Set-PSReadLineKeyHandler -Key ')', ']', '}' `
    -BriefDescription SmartCloseBraces `
    -LongDescription "Insert closing brace or skip" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

# 删除成对的符号
Set-PSReadLineKeyHandler -Key Backspace `
    -BriefDescription SmartBackspace `
    -LongDescription "Delete previous character or matching quotes/parens/braces" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0) {
        $toMatch = $null
        if ($cursor -lt $line.Length) {
            switch ($line[$cursor]) {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}

# 清理当前命令，并直接将其保存到历史记录中
Set-PSReadLineKeyHandler -Key Alt+w `
    -BriefDescription SaveInHistory `
    -LongDescription "Save current line in history but do not execute" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# 显示整个历史记录的界面
Set-PSReadLineKeyHandler -Key F7 `
    -BriefDescription History `
    -LongDescription 'Show command history' `
    -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern) {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
            if ($line.EndsWith('`')) {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines) {
                    "$lines`n$line"
                }
                else {
                    $line
                }
                continue
            }

            if ($lines) {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title History -PassThru
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}

#endregion 自定义快捷键

#region 设置命令别名

Set-Alias -Name ll -Value Get-ChildItem

#endregion 设置命令别名

#region 扩展命令

# 打开 wsl 所需环境
function Open-CzWslEnvironment {
    # 打开虚拟平台服务
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    
    # 打开 WSL 服务
    # dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    # Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux 
}

# 关闭 wsl 所需环境
function Close-CzWslEnviroment {
    Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    # Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux 
}

# 获取 PowerShell 版本
function Get-CzPSVersion {
    $PSVersionTable
}

# 打开 hosts 文件
function Open-CzHosts {
    code C:\Windows\System32\drivers\etc\hosts
}

# 查看 hosts 数据
function Get-CzHosts {
    param (
        $Domain
    )

    if ([String]::IsNullOrEmpty($Domain)) {
        Get-Content C:\Windows\System32\drivers\etc\hosts
    }
    else {
        Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String $Domain
    }
}

# 设置环境变量
function Set-CzSystemEnv {
    param (
        $Name,
        $Val
    )
    [Environment]::SetEnvironmentVariable($Name, $Val, 'Machine')
}

# 获取系统环境变量
function Get-CzSystemEnv {
    param (
        $Name
    )

    if ([String]::IsNullOrEmpty($Name)) {
        Get-ChildItem env: 
    }
    else {
        Get-ChildItem env: | where Name -Match $Name
    }
}

# 连接 Redis
function Connect-Redis {
    param (
        $RedisHost,
        $RedisPort,
        $RedisPwd
    )
    
    if ([String]::IsNullOrWhiteSpace($RedisHost)) {
        $RedisHost = 'localhost'
    }

    if ([String]::IsNullOrWhiteSpace($RedisPort)) {
        $RedisPort = 6379
    }

    if ([String]::IsNullOrWhiteSpace($RedisPwd)) {
        .\Redis-x64-3.2.100\redis-cli.exe -h $RedisHost -p $RedisPort
    }
    else {
        .\Redis-x64-3.2.100\redis-cli.exe -h $RedisHost -p $RedisPort -a $RedisPwd
    }
}

#endregion 扩展命令
