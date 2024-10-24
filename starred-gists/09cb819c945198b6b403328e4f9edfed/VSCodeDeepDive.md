# Visual Studio Code Deep Dive

David Wilson - [@daviwil](https://twitter.com/daviwil)
Software Engineer, PowerShell Team

## Overview

1. Visual Studio Code overview
2. Configuring the editor
3. Extensions
4. PowerShell support

## Overview

### Command Palette

- Launch with <kbd>Ctrl+Shift+P</kbd> or <kbd>F1</kbd>
- Interactive search of all commands as you type
- Key bindings are listed to the right
- Some commands give you more menus, like "File: Open Recent"
- <kbd>Ctrl+P</kbd> to get the file switcher
- <kbd>Ctrl+Shift+O</kbd> lets you navigate between symbols in the open file

### Folder browser

- A folder is treated as a workspace
- Difference between having a folder open or not
- Biggest difference is task and debugger configurations
- Folders allow workspace-specific settings
- Source control (Git) is activated

### Source Control

#### Git

If your workspace folder has a .git folder, you get a great Git experience
out of the box.

- Diffing
- Staging files
- Committing
- Pushing commits
- Pulling from remotes
- Creating and switching branches

Try out GitLens for even more good stuff!

Other VCS'es should be supported soon, new SCM APIs in VS Code 1.11.

### Panels

- Problems
- Output
- Debug Console
- Terminal

### Integrated Terminal

- SUPER FAST
- Supports any shell!
  - PowerShell with PSReadline
  - Bash for Windows
  - Anything on Linux or macOS: zsh, fish, etc

### Tasks

- Running tasks using external programs
  - Build
  - Test
  - Deploy
- tasks.json in your workspace folder
- Configure a particular program to be run
- You can run your psake or Invoke-Build scripts!
- Output goes to Output window unless you use the new terminal runner (set `version` to `2.0.0`)

### Debugging

Great debugging experience, we'll talk about this when we talk about
the PowerShell extension.

### Other Cool Stuff

- "Hot Exit": retains unsaved files on exit, restores on next session
- Markdown preview: <kbd>Ctrl+Shift+V</kbd>
- Zen mode: <kbd>Ctrl+K Z</kbd>
- Side by side editing: <kbd>Ctrl+\</kbd>

## Configuration

### User Settings

Open the configuration page by clicking `File -> Preferences -> Settings` or
pressing <kbd>Ctrl+,</kbd> (comma).

Settings are searchable!

In the left pane, over over a setting and click the pencil icon to add the
setting to your user settings file.

### Workspace Settings

Override any user settings at the project level by editing your `.vscode\settings.json`
file.  You can also edit these in the settings editor by clicking "Workspace Settings"
on the right side of the search bar of the Settings editor tab.

### Useful Settings

- `editor.fontSize`
- `editor.fontFamily`
- `editor.insertSpaces` - Spaces, not tabs!
- `editor.formatOnSave` - Format your code just before it's saved
- `editor.formatOnType` - Format your code as you type!

- `files.defaultLanguage`: Set the default language for files created with <kbd>Ctrl+N</kbd>
- `files.autoSave`: Save your files automatically as you edit them, very configurable

- `terminal.integrated.fontSize` - Override `editor.fontSize in the integrated terminal
- `terminal.integrated.fontFamily` - Override `editor.fontFamily` in the integrated terminal

### Theme Settings

- Workbench and syntax theming
  - Run "Preferences: Color Theme"
  - Try [Sapphire](https://marketplace.visualstudio.com/items?itemName=Tyriar.theme-sapphire) by [@Tyriar](https://twitter.com/Tyriar)!
- Icon themes
  - Run "Preferences: File Icon Theme"
  - Try Seti (built in) or [vscode-icons](https://marketplace.visualstudio.com/items?itemName=robertohuertasm.vscode-icons)

## Extensions

### Finding and Installing Extensions

To browse extensions, launch the Extensions pane by clicking the icon in the
left sidebar or pressing <kbd>Ctrl+Shift+X</kbd>.

Click the `...` and click "Show Recommended Extensions" or "Show Popular Extensions" to
find recommended and popular extensions.

Click the green "Install" button to install.  A "Reload" will be required to
activate the extension.

To automatically update extensions, you configure `extensions.autoUpdate` to `true`.

### Cool Extensions

- [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Vim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim)
- [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync)

Check out other [popular extensions](https://marketplace.visualstudio.com/vscode) on
the Visual Studio Marketplace!


## The PowerShell Extension

### General editing features

- IntelliSense with paramset signatures and doc strings
- Syntax and rule-based analysis
- Code fixes
- Code formatting
- Basic symbol renaming
- Code navigation (Go to Definition <kbd>F12</kbd>, Find All References)

### Integrated Console

- Fully integrated experience
- Press F8 in the editor to run current line or selection (right-click menu also)
- $psEditor!
  - Try out some API calls
  - `$psEditor.Window.ShowErrorMessage("BOOM")`
  - `$psEditor.Window.SetStatusBarMessage("Hello!", 2000)`
  - `psedit <file path>`
  - Check out the (slightly out of date) [documentation](http://powershell.github.io/PowerShellEditorServices/guide/extensions.html)

### Debugging

- For basic PowerShell script debugging, just press F5!
- For everything else, you can create a `launch.json` configuration
- Debugging a specific script file
- Debugging modules (Plaster)
- Debugging Pester tests ("Interactive Session" configuration)
- Column breakpoints, stepping into pipelines
  - `Get-Process | % { Write-Host $_.Name }`

## Other resources

- [VS Code Tips and Tricks](https://github.com/Microsoft/vscode-tips-and-tricks)
- [Visual Studio Code Insiders](https://code.visualstudio.com/insiders)
