- [Links](#links)
- [Important for loading](#important-for-loading)
- [Recommend auto-format](#recommend-auto-format)
- [VS Code Icons](#vs-code-icons)
- [Integrated Terminal Config](#integrated-terminal-config)
- [`[powershell]` section](#powershell-section)


## Links

- [docs: variable cheatsheet](https://code.visualstudio.com/docs/editor/variables-reference)

## Important for loading

```jsonc
"powershell.enableProfileLoading": true,
"powershell.integratedConsole.focusConsoleOnExecute": true,
"powershell.integratedConsole.showOnStartup": true,
"powershell.integratedConsole.suppressStartupBanner": true,
"powershell.startAutomatically": true,
```

    
## I highly recommend these `codeFormatting` values

```jsonc
"files.defaultLanguage": "${activeEditorLanguage}",
"powershell.codeFormatting.alignPropertyValuePairs": true,
"powershell.codeFormatting.autoCorrectAliases": true,
"powershell.codeFormatting.useConstantStrings": true,
"powershell.codeFormatting.useCorrectCasing": true,
"powershell.scriptAnalysis.settingsPath": "C:/dotfiles/powershell/PSScriptAnalyzerSettings.psd1",
  ```


## `[powershell]` section

Some people really prefer the different word separators, here's the main variations
One makes ctrl+d and splats easier. 

```jsonc
"[powershell]": {
    "editor.formatOnSave": true,
    "editor.wordSeparators": "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?", // break on $ and -
    "editor.wordSeparators": "`~!@#%^&*()=+[{]}\\|;:'\",.<>/?", // combine $ and -
    "editor.wordSeparators": "`~!@#%^&*()-=+[{]}\\|;:'\",.<>/?",
    "editor.snippetSuggestions": "bottom",
    "files.encoding": "utf8bom",
    "editor.formatOnPaste": true,
    "files.trimTrailingWhitespace": true,
    ////
    "editor.quickSuggestions": {
        "other": true, "comments": false, "strings": true },
    "editor.wordBasedSuggestionsMode": "matchingDocuments",
}
```

## Check out
  
  ```jsonc
"terminal.integrated.defaultProfile.windows": "Pwsh🐒",
"workbench.editor.languageDetection": true,
"powershell.promptToUpdatePackageManagement": false,
"powershell.promptToUpdatePowerShell": false,
"terminal.integrated.defaultLocation": "editor",
"editor.bracketPairColorization.enabled": true,
"editor.semanticHighlighting.enabled": true,
"powershell.codeFormatting.newLineAfterOpenBrace": false,
"powershell.codeFormatting.preset": "OTBS",
"powershell.codeFormatting.trimWhitespaceAroundPipe": true,
"powershell.codeFormatting.whitespaceAroundPipe": true,
"powershell.codeFormatting.whitespaceBetweenParameters": false,    
"powershell.powerShellDefaultVersion": "PowerShell (x64)",
    "files.associations": {
        "*.json": "jsonc",
        // powershell
        "*.ps1xml": "xml",
        // microsoft / vs studio
        "*.wixproj": "xml",
        "*.mproj": "xml",
        "*.odc": "html",
        "nuget.config": "xml",
        "*.psm1": "powershell",
    },
```

## Testing addons and Pester

```jsonc
// testing addons
"errorLens.enabled": true,
"errorLens.gutterIconsEnabled": true,
"pester.suppressCodeLensNotice": true,
"pesterExplorer.autoDiscoverOnOpen": true, 
"powershell.helpCompletion": "BlockComment",
"powershell.pester.debugOutputVerbosity": "Detailed",
"powershell.pester.outputVerbosity": "FromPreference",
"terminal.explorerKind": "integrated",
"testExplorer.addToEditorContextMenu": true,
"testExplorer.gutterDecoration": true,
"testExplorer.onStart": null,
"testExplorer.useNativeTesting": true,
"testing.automaticallyOpenPeekViewDuringAutoRun": false,
"testing.autoRun.mode": "rerun",
"testing.defaultGutterClickAction": "debug",
"testing.followRunningTest": true,
"testing.gutterEnabled": true,
"powershell.pester.useLegacyCodeLens": false, // might be an addon
"pesterExplorer.autoDiscoverOnOpen": true,
```

## Schema's autocomplete when writing `Format.ps1xml` and `Type.ps1xml`

```jsonc

// schema for Powershell
"xml.fileAssociations": [
    {
        "systemId": "https://raw.githubusercontent.com/PowerShell/PowerShell/master/src/Schemas/Format.xsd",
        "pattern": "**/*.Format.ps1xml"
    },
    {
        "systemId": "https://raw.githubusercontent.com/PowerShell/PowerShell/master/src/Schemas/Types.xsd",
        "pattern": "**/*.Types.ps1xml"
    }
],
```

## VS Code Icons: Distinguish tests from scripts

```jsonc
{
    "workbench.iconTheme": "vscode-icons",
    "vsicons.associations.files": [
        // justin grote's config: <https://discord.com/channels/180528040881815552/447476910499299358/801102446209794088> { "extensions": [ "arm.json" ], "format": "svg", "icon": "azure" },
        { "extensions": [ "parameters.json" ], "format": "svg", "icon": "config" },
        { "extensions": [ "tests.ps1" ], "format": "svg", "icon": "test" },
        { "extensions": [ "clixml" ], "format": "svg", "icon": "xml" }
    ],
    "vsicons.associations.folders": [
        { "extends": "dist", "extensions": [ "BuildOutput", "Output" ], "format": "svg", "icon": "dist" },
        { "extends": "helper", "extensions": [ "BuildHelpers" ], "format": "svg", "icon": "helper" }
    ]
}
```

## Integrated Terminal Config

```jsonc
      details

          https://code.visualstudio.com/docs/editor/variables-reference
      */
"terminal.integrated.profiles.windows": {
"Pwsh🐒": {
    "color": "terminal.ansiMagenta",
    "overrideName": true,
    "path": [ "pwsh.exe", "C:/Program Files/PowerShell/7/pwsh.exe" ],
    "args": [ "-NoLogo" ],
    "icon": "terminal-powershell"
},
"Command Prompt": {
    "path": [ "${env:windir}\\Sysnative\\cmd.exe", "${env:windir}\\System32\\cmd.exe" ],
    "args": [], "icon": "terminal-cmd"
},
"Git Bash": {
    "source": "Git Bash", "icon": "terminal-bash"
},
"Pwsh -NoProfile": {
    "overrideName": true,
    "path": [ "pwsh.exe", "C:/Program Files/PowerShell/7/pwsh.exe" ],
    "args": [ "-NoProfile", "-NoLogo" ],
    "icon": "terminal-powershell"
},
"Windows PowerShell -NoP": {
    "overrideName": true,
    "icon": "arrow-both",
    "path": "C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
    "args": [ "-NoLogo", "-NoProfile" ]
},
```