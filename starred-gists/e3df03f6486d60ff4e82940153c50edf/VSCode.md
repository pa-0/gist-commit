
# AHK Debugging with Visual Studio Code

Created on 2021/11/03 with VSCode version **1.53**.\
Last revision on 2022/06/30 with VSCode version **1.68.2**.

I'm not a native English speaker, so please report inconsistencies to [u/anonymous1184][00] (or send a `.patch` of the [source][01]).

## Table of Contents

1. [TL;DR: 5-minute cookbook recipe](#tldr-5-minute-cookbook-recipe)
1. [Choosing a version](#choosing-a-version)
1. [Installing VSCode](#installing-vscode)
  * [Portable version](#portable-version)
1. [Extensions](#extensions)
  * [AutoHotkey++](#autohotkey)
  * [Optional](#optional)
    * [Bookmarks](#bookmarks)
    * [Diff](#diff)
    * [Overtype](#overtype)
    * [Sublime Text keymap](#sublime-text-keymap)
    * [vscode-autohotkey-debug](#vscode-autohotkey-debug)
1. [Usage Examples](#usage-examples)
  * [OutputDebug](#outputdebug)
  * [Breakpoints](#breakpoints)
  * [Debug Actions](#debug-actions)
  * [More](#more)
1. [Profiles](#profiles)
1. [Misc. configurations](#misc-configurations)
  * [Workspace trust](#workspace-trust)
  * [Fix <kbd>F9</kbd> overlap](#fix-f9-overlap)
  * [Inline values](#inline-values)
  * [Always use BOM](#always-use-bom)
  * [Replace PowerShell](#replace-powershell)

## TL;DR: 5-Minute cookbook recipe

1. [Download][02], install, and run VSCode.
1. Pres <kbd>Ctrl</kbd>+<kbd>p</kbd> and type/paste `ext install mark-wiemer.vscode-autohotkey-plus-plus` then press <kbd>Enter</kbd> to install extension that handles `.ahk` files.
  * ***<u>Optionally</u>*** this one<sup>1</sup>: Press <kbd>Ctrl</kbd>+<kbd>p</kbd> type/paste `ext install zero-plusplus.vscode-autohotkey-debug` then press <kbd>Enter</kbd>.
1. Press <kbd>Ctrl</kbd>+<kbd>n</kbd> to create a new document and type/paste:
  <details>
    <summary><code>Untitled-1</code></summary>

  ```ahk
  #Warn All, OutputDebug
  hello := "Hello "
  world := "World!"
  OutputDebug % hello world
  OutputDebug % test123test
  ```

  </details>

1. Save the document with `.ahk` as the extension.
1. Press <kbd>F9</kbd> to debug and see the:
  <details>
    <summary>Debug Console</summary>
    <img src="https://user-images.githubusercontent.com/53758552/109747708-430dec80-7b9d-11eb-9f54-c538b3bf83a9.png" />
  </details>

**Happy debugging!** *(as if...)*

<sup>*1: If you want the [optional](#vscode-autohotkey-debug "vscode-autohotkey-debug") benefits of the second extension.*</sup>

## Choosing a version

Depending on your OS and type of processor, you are better off with the corresponding architecture; so [if you have a 64-bit OS][03], use the x64 version as it would have speed improvements<sup>2</sup> over the x86 version.

Upon clicking the Windows button (instead of the specific build), the website will make an educated guess and deliver what it considers best.

A more specific installation can be chosen between a *System* and *User* type of installation; the first option places the application in `%ProgramFiles%` while the other places it in `%LocalAppData%`.

<sup>*2: Not life-changing improvements, when compiled the instruction sets on the processor are taken into account to have more stability rather than raw speed*.</sup>

## Installing VSCode

This is your basic run-of-the-mill installer with a License Agreement and a few screens, in the end you're presented with the option to launch the installed application (please do). The process is shown below:

<details>
  <summary>License Agreement</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109805030-9194a880-7be8-11eb-9612-98e544f60fa4.png" />
</details>

<details>
  <summary>Destination Location</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109747804-69cc2300-7b9d-11eb-86c7-3e7bb9a40779.png" />
</details>

<details>
  <summary>Start Menu Folder</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109747826-7486b800-7b9d-11eb-9f11-835ec21f1934.png" />
</details>

<details>
  <summary>Additional Tasks</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109747858-81a3a700-7b9d-11eb-83ed-44b3d692b50c.png" />
</details>

<details>
  <summary>Ready to Install</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109747893-8f592c80-7b9d-11eb-8248-30597b11a397.png" />
</details>

<details>
  <summary>Completed</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109747921-98e29480-7b9d-11eb-8492-d394f4e3fd43.png" />
</details>

### Portable version

*The* `AutoUpdate.ahk` *script below takes care of everything, just put it in an empty folder and run it, no need for manual download/decompression.*

---

If you want to use VSCode with the same settings on more than one computer but also don't want to log in to an account or don't have administrator access (or simply feel more in control with a stand-alone installation) download either the [x64][04] or the [x86][05] zip archive.

Once uncompressed, create an empty directory called `data` (and if you desire to keep temporal files outside the current user environment create a `tmp` directory inside).

The possible downside of this method of "installation" is that updates are not automatic, they need to be done manually. For that purpose, placing this script in the directory will do the job:

<details>
  <summary><code>AutoUpdate.ahk</code></summary>

```ahk
;
; Configuration ↓
;

#NoTrayIcon ; Don't show an icon

x64 := true ; Use 64 bit

;
; Configuration ↑
;

; No sleep
SetBatchLines -1

; Check if running
if (WinExist("ahk_exe " A_ScriptDir "\Code.exe")) {
    MsgBox 0x40024, Continue?, VSCode is running`, continue wit the update?
    IfMsgBox No
        ExitApp 1
}

; Get latest version information
x64 := (x64 && A_Is64bitOS)
url := "https://update.code.visualstudio.com/latest/win32" (x64 ? "-x64-" : "-") "archive/stable"
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("HEAD", url, false), whr.Send()
headers := whr.GetAllResponseHeaders()
Sort headers

; Extract relevant information
regex := "is)(?<Name>[^""]+\.zip).*Length: (?<Size>\d+)"
RegexMatch(headers, regex, file)
if (!fileName || !fileSize) {
    MsgBox 0x40010, Error, Couldn't get the information from the link.
    ExitApp 1
}

; Check if already updated
FileCreateDir % A_ScriptDir "\data"
fileName := A_ScriptDir "\data\" fileName
FileGetSize currSize, % filename
if (FileExist(fileName) && !currSize) {
    MsgBox 0x40040, Updated, Already up-to-date.
    ExitApp
}

; Remove last downloaded version
FileDelete % A_ScriptDir "\data\VSCode-*.zip"

; Filesize
mb := Round(fileSize / 1024 / 1024, 2)

; Progress Window
Gui Download:New, +AlwaysOnTop +HWNDhGui -SysMenu +ToolWindow
Gui Font, q5 s11, Consolas
Gui Add, Text,, % "Downloading...    " ; +4
Gui Show,, % "> Downloading " mb " MiB"
Hotkey IfWinActive, % "ahk_id" hGui
Hotkey !F4, WinExist

; Download
SetTimer Percentage, 50
UrlDownloadToFile % url, % fileName
if (ErrorLevel) {
    MsgBox 0x40010, Error, Error while downloading.
    FileDelete % A_ScriptDir "\data\VSCode-*.zip"
    ExitApp 1
}
SetTimer Percentage, Delete
Gui Download:Destroy

; Close if running
WinKill % "ahk_exe " A_ScriptDir "\Code.exe"

; Extract
shell := ComObjCreate("Shell.Application")
items := shell.Namespace(fileName).Items
shell.Namespace(A_ScriptDir).CopyHere(items, 16 | 256)

; Truncate the file
FileOpen(fileName, 0x1).Length := 0

; Empty temp files
if (FileExist(A_ScriptDir "\data\tmp")) {
    FileRemoveDir % A_ScriptDir "\data\tmp", 1
    FileCreateDir % A_ScriptDir "\data\tmp"
}

; Run
Run Code.exe, % A_ScriptDir


ExitApp ; Finished


; Progress
Percentage:
    FileGetSize size, % fileName
    GuiControl Download:, Static1, % "Downloaded: " Round(size / fileSize * 100, 2) "%"
return
```

</details>

## Extensions

The core functionality of VSCode can be easily extended with the Extensions Marketplace; it is a well-established ecosystem with a wide variety of additions for different programming languages, spoken languages, data/file types, *et cetera*... worth exploring.

AutoHotkey support in VSCode is not bundled out of the box, thus extensions allow full utilization of IDE features (such as syntax highlighting, [IntelliSense][06], formatting, contextual help, **<u>debug</u>**...).

While there are a few AutoHotkey-related extensions available, the one made by [Mark Wiemer][07] is the most up-to-date and actively developed. It has everything most users might need to write and debug AutoHotkey scripts. For more advanced usage look into the extension referred to in the [next subtopic](#optional "Optional Extensions"). It is advised to read as much as possible about what can be accomplished with the extension.

To install the required extension click "Extensions" in the "Activity Bar" (the 5th icon on the left bar, or press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>). Type (or copy and paste) the extension id: `mark-wiemer.vscode-autohotkey-plus-plus` and press <kbd>Enter</kbd>.

### AutoHotkey++

<details>
  <summary>Extension: AutoHotkey Plus Plus</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109748022-c3345200-7b9d-11eb-8b86-6b365393184c.png" />
</details>

In order to test create a new file (press <kbd>Ctrl</kbd>+<kbd>n</kbd>) and type/paste:

<details>
  <summary><code>test.ahk</code></summary>

```ahk
#Warn All, OutputDebug
hello := "Hello "
world := "World!"
OutputDebug % hello world
OutputDebug % test123test
```

</details>

Save the file with `.ahk` as extension and press <kbd>F9</kbd><sup>3</sup> to test the debugger. The expected result is a very unoriginal `Hello World!` and a warning that in the line \#5 an undefined variable was called:

<details>
  <summary>Debug Console</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109748068-d21b0480-7b9d-11eb-831b-0758cb27a951.png" />
</details>

Normally a `MsgBox` would have been issued for the warning:

<details>
  <summary>Warning</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109748128-f0810000-7b9d-11eb-8221-d2a3b87fb81d.png" />
</details>

<sup>*3: Oddly, this shortcut is a default binding in the extension but also overrides toggling breakpoints; to address the issue refer to [Fix <kbd>F9</kbd> overlap](#fix-f9-overlap "Fix F9 overlap")*.</sup>

### Optional

The following are a few extensions that have a positive impact on the overall coding experience IMO (as always YMMV). The procedure to install them is the same as before:

1. Press (<kbd>Ctrl</kbd>+<kbd>p</kbd>).
1. Type/paste `ext install` followed by a space and the extension ID.
1. Hit <kbd>Enter</kbd> and after a few seconds, the extension is installed.

However, you could also take the scenic route to find out more about the extension's details. In that case, try the following instead:

1. Click "Extensions" in the "Activity Bar" (or press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>x</kbd>).
1. Type/paste the extension ID, press <kbd>Enter</kbd>, and review.
1. If you wish to proceed, click on the small `install` button.

#### Bookmarks

Jumping between sections of code is something you'll always find yourself doing when dealing with files that require you to scroll is a nuance. There are of course methods to avoid manually looking through a file like the "Code Outline", "Go to Definition" or "Go to References", but what happens when you need to jump between parts in the middle of a "node"? Or simply to avoid using the mouse? Well, [Bookmarks][08] is exactly for that.

* ID: `alefragnani.bookmarks`

#### Diff

VSCode has inline Diff support but only when working in a project with SCM configured, for chunk-based diff (with Clipboard support) [Partial Diff][09] is useful.

* ID: `ryu1kn.partial-diff`

When dealing with a file as a whole and inline changes or side-to-side comparison is needed [Diff][10] will provide access to the built-in feature normally only available through the command line (`Code.exe --diff path1 path2`).

* ID: `fabiospampinato.vscode-diff`

#### Overtype

This is the first editor I've used without native support for overtype, weird.

* ID: `adammaras.overtype`

#### Sublime Text keymap

If you ever used Sublime Text Editor and got used to its bindings, a must is to keep consistency or avoid re-training muscle memory. A big plus of [this extension][11] is that it imports/translates the configuration of Sublime Text into VSCode.

* ID: `ms-vscode.sublime-keybindings`

#### vscode-autohotkey-debug

While Mark's extension is more than enough for the majority of users, I've found that the (unnamed) extension provided by [zero-plusplus][12] has a broader set of functionality aimed at more nitpicking/advanced users. Again, take your time to read and consider if this extension provides an improvement over what's already on the table (a comparison between the two is out of the scope of this guide).

* ID: `zero-plusplus.vscode-autohotkey-debug`

## Usage Examples

This is not a comprehensive tutorial, but a quick guide aimed at covering the basics of how to effectively enable and utilize AHK debugging support in VSCode.

### OutputDebug

[`OutputDebug`][13] simply sends an evaluated expression in the form of a string to the connected debugger for display in the console:

<details>
  <summary><code>test.ahk</code></summary>

```ahk
foo := {}
foo.bar := "Hello "
foo["baz"] := "World!"
OutputDebug Hello World!               ; Plain string
OutputDebug % foo["bar"] foo.baz       ; Object properties
OutputDebug % "Hello" A_Space "World!" ; String concatenation
```

</details>

<details>
  <summary>Debug Console</summary>
  <p>(<i>Mixed properties declaration/call in the object are intentional</i>).</p>
  <img src="https://user-images.githubusercontent.com/53758552/109751621-83bd3400-7ba4-11eb-9dd4-e93f3de7b3c5.png" />
</details>

Additional benefits against methods like:

* `MsgBox`: it doesn't halt code execution.
* `ToolTip`: you can print/review several lines.
* `FileAppend`: no need to keep "tailing" a log file.

To halt code execution, we have:

### Breakpoints

Breakpoints allow the user to stop at any given line and inspect the code mid-execution, enabling manual review and modification of variables on-the-fly for any scope.

To set a breakpoint click to the left of the line numbers, or set up a keyboard shortcut (look for `Debug: Toggle Breakpoint`) the default <kbd>F9</kbd> is overwritten but you can [fix it](#fix-f9-overlap "Fix F9 overlap").

Breakpoints can be set in any line but if they are set in comments or directives the interpreter will stop in the next available statement. In the following example, a breakpoint is set inside a `loop`, inside a function.

After setting the breakpoint, start the debugger by:

* Press <kbd>F5</kbd>.
* From the menu: Run > Start Debugger.
* Clicking the "play" button on the top right corner.

<details>
  <summary>Start of the <code>loop</code></summary>
  <img src="https://user-images.githubusercontent.com/53758552/109777214-140d7000-7bc9-11eb-8262-e2f5cca90f1b.png" />
</details>

<details>
  <summary><code>loop</code>, second iteration</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109777212-1374d980-7bc9-11eb-8e0b-b519fd6e3b40.png" />
</details>

<details>
  <summary><code>loop</code>, third iteration</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109777210-1374d980-7bc9-11eb-8438-7c81db05acc9.png" />
</details>

<details>
  <summary><code>loop</code>, last iteration</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109777207-12dc4300-7bc9-11eb-94e9-9dd823640a1a.png" />
</details>

<details>
  <summary>Session finished</summary>
  <img src="https://user-images.githubusercontent.com/53758552/109777206-12dc4300-7bc9-11eb-8c17-3c30648b88f4.png" />
</details>

### Debug Actions

The basic actions on the vast majority of debuggers are:

* **Continue**: Resumes the execution until the next breakpoint or end of the thread.
* **Step Over**: Evaluates the next statement ahead.
* **Step Into**: Goes inside the next statement (if user-defined).
* **Step Out**: Continues to the upper layer in the stack.

### More

For a more robust guide, please refer to the [VSCode Documentation][14] where you can read about Evaluation (directly in the console), "Variable Watch", "Call Stack", how to monitor variable values and set (Conditional<sup>4</sup>) Breakpoints at different layers of the stack when "tracing".

After this point, virtually every debugging tutorial explains the same concepts (once you remove language from the equation). For even more details: search engines, forums, subreddits, IRC/Discord servers, etc. can be of great help.

<sup>*4: Only with `vscode-autohotkey-debug` extension.*</sup>

## Profiles

Profiles can be set to test various versions of AHK (ANSI, Unicode x86/x64, AHK_H, v2) and to start debugging a specific file (instead of the one currently in the editor). Click the "Run" icon in the "Activity Bar" (or press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>d</kbd>) and click on the `create a launch.json file` link, a boilerplate will be created:

<details>
  <summary><code>launch.json</code></summary>

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "ahk",
      "request": "launch",
      "name": "AutoHotkey Debugger",
      "program": "${file}",
      "stopOnEntry": true
    }
  ]
}
```

</details>

* `type`: must be `ahk`.
* `name`: is a free label.
* `request`: must be `launch`.
* `program`: a path to a script supports predefined variables<sup>12</sup>.
* `runtime`: is the binary used to start the debugging process<sup>12</sup>.
* `stopOnEntry`: true to stop on the first line even without a breakpoint.

<details>
  <summary>Predefined Variables</summary>

```javascript
${workspaceFolder}         // Path of the folder opened.
${workspaceFolderBasename} // Name of the folder opened (without any slashes).
${file}                    // Current opened file.
${relativeFile}            // Current opened file relative to workspaceFolder.
${relativeFileDirname}     // Current opened file's dirname relative to workspaceFolder.
${fileBasename}            // Current opened file's basename.
${fileBasenameNoExtension} // Current opened file's basename with no file extension.
${fileDirname}             // Current opened file's dirname.
${fileExtname}             // Current opened file's extension.
${cwd}                     // Task runner's current working directory on startup.
${lineNumber}              // Current selected line number in the active file.
${selectedText}            // Current selected text in the active file.
${execPath}                // Path to the running VSCode executable.
${defaultBuildTask}        // Name of the default build task.
```

</details>

<sup>*12: Paths in windows use a backslash, JSON format needs a backslash escaped with another backslash. Another option is to use a single forward slash \*NIX-style.*</sup>

To add profiles just add objects into the `configurations` array:

<details>
  <summary>Profiles example</summary>

```json
{
  "type": "ahk",
  "name": "v1 U64",
  "request": "launch",
  "program": "${workspaceFolder}\\test.ahk",
  "runtime": "C:\\Program Files\\AutoHotkey\\AutoHotkeyU64.exe",
  "stopOnEntry": false
},
{
  "type": "ahk",
  "name": "AHK_H U32",
  "request": "launch",
  "program": "${workspaceFolder}/test.ahk",
  "runtime": "D:/repos/ahkdll/bin/Win32w/AutoHotkey.exe",
  "stopOnEntry": true
}
```

</details>

## Misc. configurations

1. [Workspace trust](#workspace-trust)
1. [Fix F9 overlap](#fix-f9-overlap)
1. [Inline values](#inline-values)
1. [Always use BOM](#always-use-bom)
1. [Replace PowerShell](#replace-powershell)

### Workspace trust

The feature is annoying and even [the authors acknowledge it][15]. To disable open the Settings (<kbd>Ctrl</kbd>+<kbd>,</kbd>) in the search bar, paste/type `security.workspace.trust.enabled` and remove the check mark.

### Fix F9 overlap

Fixing the overlapping <kbd>F9</kbd> is far easier via editing the configuration rather than going through the UI. Press <kbd>Ctrl</kbd>+<kbd>p</kbd>, type/paste `> Preferences: Open KeyboardShortcuts (JSON)` and press <kbd>Enter</kbd>; the `.json` configuration for key bindings will open. Add the following inside the brackets:

<details>
  <summary><code>keybindings.json</code></summary>

```json
{
    "key": "f9",
    "command": "-ahk++.debug",
    "when": "editorLangId == 'ahk'"
},
```

</details>

After saving, you should have the defaults:

* <kbd>F5</kbd> to start debugging.
* <kbd>F9</kbd> to toggle breakpoints.

### Inline values

To have an overlay with the parsed values of the expressions as soon as you step over them, open Settings (<kbd>Ctrl</kbd>+<kbd>,</kbd>) in the search bar, paste/type `debug.inlineValues`, and check the appropriate checkbox. Bear in mind that this can be both useful and overwhelming (too much information on-screen).

### Always use BOM

AutoHotkey only plays nice with Unicode characters if scripts have the proper character encoding (see [Byte Order Mark][16]). To enable it, on the "Command Palette" (<kbd>Ctrl</kbd>+<kbd>p</kbd>) type/paste `> Preferences: Open Settings (JSON)` and add the following:

<details>
  <summary><code>settings.json</code></summary>

```json
"[ahk]": {
  "files.encoding": "utf8bom"
}
```

</details>

### Replace PowerShell

To change the slower PowerShell for the command prompt (*ie* `cmd.exe`) or any other shell installed, open Settings (<kbd>Ctrl</kbd>+<kbd>,</kbd>) in the search bar, type/paste `terminal.integrated.defaultProfile.windows`, and select the terminal of your choice in the drop-down.

<!-- EOF -->

[00]: https://www.reddit.com/user/anonymous1184 "Reddit"
[01]: https://gist.githubusercontent.com/anonymous1184/4b5463e2e37c4a8e6873eb580a3a7f0f/raw "Raw"
[02]: https://code.visualstudio.com/Download "Download Visual Studio Code"
[03]: https://duckduckgo.com/?q=Is+my+OS+64-bit%3F "Is my OS 64bit?"
[04]: https://update.code.visualstudio.com/latest/win32-x64-archive/stable "Direct Download: 64 bits zip file"
[05]: https://update.code.visualstudio.com/latest/win32-archive/stable "Direct Download: 32 bits zip file"
[06]: https://code.visualstudio.com/docs/editor/intellisense "VSCode IntelliSense"
[07]: https://github.com/mark-wiemer/vscode-autohotkey-plus-plus#autohotkey-plus-plus-ahk "Extension: AHK++"
[08]: https://github.com/alefragnani/vscode-bookmarks#bookmarks "Extension: Bookmarks"
[09]: https://github.com/ryu1kn/vscode-partial-diff#partial-diff "Extension: Partial Diff"
[10]: https://github.com/fabiospampinato/vscode-diff#diff "Extension: Diff"
[11]: https://github.com/Microsoft/vscode-sublime-keybindings#sublime-importer-for-vs-code "Extension: Sublime Importer for VS Code"
[12]: https://github.com/zero-plusplus/vscode-autohotkey-debug#overview "Extension: vscode-autohotkey-debug"
[13]: https://www.autohotkey.com/docs/commands/OutputDebug.htm "AutoHotkey Help: OutputDebug"
[14]: https://code.visualstudio.com/docs/editor/debugging "VSCode Help: Debugging"
[15]: https://code.visualstudio.com/blogs/2021/07/06/workspace-trust
[16]: https://en.wikipedia.org/wiki/Byte_Order_Mark "Wikipedia: Byte Order Mark"

<!-- cSpell:ignore \(#[^)]+\) -->
<!-- cSpell:ignore (^|\s)`[^`]+` -->
<!-- cSpell:ignore Overtype keymap autohotkey Hwnd Consolas Wiemer plusplus subreddits Extname ahkdll -->
