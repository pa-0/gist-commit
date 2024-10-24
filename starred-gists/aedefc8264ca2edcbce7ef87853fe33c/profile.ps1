Import-Module -Name posh-git
Import-Module PSReadLine

# custom functions
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
Set-Alias -Name amiadmin -value Test-Administrator -Option AllScope

Invoke-Expression ". '$([System.IO.Path]::GetDirectoryName($profile.CurrentUserAllHosts))\Scripts\SelfSign-Ps1.ps1'"

function cddash {
    if ($args[0] -eq '-') {
        $pwd = $OLDPWD;
    } else {
        $pwd = $args[0];
    }
    $tmp = pwd;

    if ($pwd) {
        Set-Location $pwd;
    }
    Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}
Set-Alias -Name cd -value cddash -Option AllScope

function Assert-Success {
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)] $input);
    
    # pipe input through - make usable as pipeline func w/ no changes to the value passed through
    $input;

    if ($LASTEXITCODE -ne 0) {
        throw "The last operation fialed with an exit code of $LASTEXITCODE"
    }
}
function Out-Tempfile {
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)] $input);

    $tempFile = New-TemporaryFile;

    try {
        $input | Out-File -FilePath $tempFile.FullName -Append -Encoding ASCII;

        subl -w $tempFile.FullName;
    }
    finally {
        Remove-Item $tempFile;
    }
}

# git functions
#** stashes the unstaged files only, using a temporary commit to isolate staged files **#
function Git-Stash-Unstaged {
    $name = "Stash Unstaged: $(If ([string]::IsNullOrEmpty($args[0])) { "$(get-date -f yyyy-MM-dd)" } Else { $args[0] })";
    # temp commit of your staged changes:
    git commit --message "chore: WIP" | Assert-Success;

    # -u option so you also stash untracked files
    git stash -u -m $name | Assert-Success;

    # now un-commit your WIP commit:
    git reset --soft HEAD^ | Assert-Success;
}
Set-Alias -Name gitStashUnstaged -Value Git-Stash-Unstaged -Option AllScope

#** adds non-whitespace changes (per file) to the index **#
function Git-Add-Non-Whitespace-Changes {
    $startLocation = Get-Location; 
    $root = git rev-parse --show-toplevel; 
    # the git apply (below) needs to be in the project root directory
    Set-Location -Path "$root";
    $staged = git diff --name-only --cached;
    # cycle staged files
    git add -A;
    git reset;
    # stage significant changes
    git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -;
    # stage new files
    git add $(git ls-files -o --exclude-standard);
    # stage files that were staged at start
    git add $staged;
    #return to original woeking directory
    Set-Location -Path "$startLocation";
    Write-Output "Adding non whitespace changes complete";
}
Set-Alias -Name gitAddSignificant -Value Git-Add-Non-Whitespace-Changes -Option AllScope

function Git-Inspect-Stash {
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)] $entry, [Alias('d')] [switch]$details);

    if ($entry -eq $null) {
        $entry = $args[0];
    } 
    if ($entry -eq $null) {
        $entry = 0;
    } 
    if (($entry -is [int]) -or ($entry -match "^[\d]+$")) {
        $entry = "stash@{$entry}";
    }

    $name = git name-stash $entry;
    $branch = $name.Substring(3, -3 + $name.IndexOf(": "));
    $message = $name.Substring($name.IndexOf(": ") + 2);

    $updatedNames = git show $entry --name-only  | Select -Skip 7;
    $newNames = git show "$entry^3" --name-only  | Select -Skip 6;
    $stagedNames = git show "$entry^2" --name-only  | Select -Skip 6;
    "---------- SUMMARY ----------";
    "=============================";
    "ENTRY     $entry";
    "BRANCH    $branch";
    "MESSAGE   $message";
    "";
    "STAGED    $($stagedNames.Count)";
    "UPDATED   $($updatedNames.Count)";
    "NEW       $($newNames.Count)";
    "-----------------------------";
    "TOTAL     $($stagedNames.Count + $newNames.Count + $updatedNames.Count)";
    if ($stagedNames.Count -gt 0) {
        "`n---------- STAGED FILES ----------";
        $stagedNames;
    }
    if ($updatedNames.Count -gt 0) {
        "`n---------- UPDATED FILES ----------";
        $updatedNames;
    }
    if ([int]$newNames.Count -gt 0) {
        "`n---------- NEW FILES ----------";
        $newNames;
    }
    if ($details) {
        "`n`n----- DETAILS -----";
        if ($stagedNames.Count -gt 0) {
            "`n---------- STAGED FILES ----------";
            git show -p "$entry^2";
        }
        if ($updatedNames.Count -gt 0) {
            "`n---------- UPDATED FILES ----------";
            git show -p $entry;
        }
        if ($newNames.Count -gt 0) {
            "`n---------- NEW FILES ----------";
            git show -p "$entry^3";
        }
    }
}
Set-Alias -Name gitInspectStash -Value Git-Add-Non-Whitespace-Changes -Option AllScope

function Git-Setup-Global {

}
function Git-Setup-Repo {
    git config core.fscache=false;

}
function Git-Setup {
    git config --global user.name "John Scott";

    git config --global core.fscache false;

    git config --global core.editor 'code --wait';
    git config --global merge.tool vscode;
    git config --global mergetool.vscode.cmd 'code --wait $MERGED';
    git config --global diff.tool vscode;
    git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE';

    git config --global --replace-all alias.root 'rev-parse --show-toplevel';
    git config --global --replace-all alias.br "for-each-ref --sort=committerdate refs/heads/ --format='%(color:yellow)%(refname:short)%(color:reset) %(color:red)%(objectname:short)%(color:reset) (%(color:green)%(committerdate:relative)%(color:reset))`n%(contents:subject)`n'";
    git config --global --replace-all alias.name-stash "!~/scripts/git-name-stash.sh";
    # need to get the merge message costomized to include the prefix
    # git config --global --replace-all alias.name-stash '!git stash push -u -m "Stash for Origin Pull"
    # git pull origin develop
    # git stash pop;';
    # git config --global --replace-all alias.view-stash '!~/scripts/git-stash-view.sh | ~/scripts/temp-file.sh';
    # NEED TO DEBUG: the below command deleted the unstaged files, potentially because I was not using the --replace-all
    # git config --global --replace-all alias.stash-unstaged '!
    # git commit -m ''chore: WIP''
    # git stash -u -m "Stash Unstaged: `date "+%Y-%m-%d"`"
    # git reset --soft HEAD^';
}

# aliases for programs not on $PATH
Set-Alias -Name msbuild -Value "c:\Windows\Microsoft.Net\Framework64\v4.0.30319\MSBuild.exe";
Set-Alias -Name subl -Value 'C:\Program Files\Sublime Text 3\subl.exe';

# options
$ErrorActionPreference = "Stop"


Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4000
# history substring search
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Tab completion
Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete


# Dracula readline configuration. Requires version 2.0, if you have 1.2 convert to `Set-PSReadlineOption -TokenType`
Set-PSReadlineOption -Color @{
    "Command" = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator" = [ConsoleColor]::Magenta
    "Variable" = [ConsoleColor]::White
    "String" = [ConsoleColor]::Yellow
    "Number" = [ConsoleColor]::Blue
    "Type" = [ConsoleColor]::Cyan
    "Comment" = [ConsoleColor]::DarkCyan
}
# Dracula Git Status Configuration
$GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchForegroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.AfterForegroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeText = " "
$GitPromptSettings.AfterText = ""

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    #Write-Host

    # Reset color, which can be messed up by Enable-GitColors

    if (Test-Administrator) {  # Use different username if elevated
        Write-Host "(Elevated) " -NoNewline -ForegroundColor White
    }

    Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor Green
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Green

    if ($s -ne $null) {  # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host " " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor Gray
    Write-Host " " -NoNewline
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Magenta

    $global:LASTEXITCODE = $realLASTEXITCODE

    Write-VcsStatus

    Write-Host ""

    return "> "
}
