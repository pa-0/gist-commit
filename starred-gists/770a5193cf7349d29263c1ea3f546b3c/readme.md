# Big Mikey Theming
> VSCode, Windows Terminal, and Prompt

## Prerequisites:

- Install [VSCode], the [Windows Terminal], [GitHub CLI], and [Starship]
- Install the [FiraCode NF Retina] font
- Install the [Posh-Git] PowerShell module

## VSCode

This section will add the Monokai Pro themes and FiraCode font to VSCode and default to them. It also ensures whitespace is rendered in the editor and font ligatures are enabled.

- Install the [Monokai Pro] extension in VSCode, set the theme to `Monokai Pro (Filter Spectrum)`
- Set `Editor: Font Family` to: `'FiraCode NF Retina', Consolas`
- Set `Editor: Render Whitespace` to: `all`
- Set `Editor: Font Ligatures` to: `true`

## Windows Terminal

This section will add the Monokai (Spectrum Filter) color pallete and FiraCode font to the Windows terminal and default to them.

- Open the settings.json for Windows Terminal (`ctrl+,`)
- Add the following to the `schemes` key:
  ```json
  {
      "name": "Monokai",
      "cursorColor": "#FFFFFF",
      "selectionBackground": "#535155",
      "background": "#363537",
      "foreground": "#F7F1FF",
      "black": "#363537",
      "blue": "#FD9353",
      "brightBlack": "#69676C",
      "brightBlue": "#FD9353",
      "brightCyan": "#5AD4E6",
      "brightGreen": "#7BD88F",
      "brightPurple": "#948AE3",
      "brightRed": "#FC618D",
      "brightWhite": "#F7F1FF",
      "brightYellow": "#FCE566",
      "cyan": "#5AD4E6",
      "green": "#7BD88F",
      "purple": "#948AE3",
      "red": "#FC618D",
      "white": "#F7F1FF",
      "yellow": "#FCE566"
  }
  ```
- Add the following to the `profiles.defaults` key:
  ```json
  "fontFace": "FiraCode NF Retina",
  "colorScheme": "Monokai"
  ```

## Starship Config
Copy the included `starship.toml` to `~/.config` on your machine.
This assumes all the prerequisites and prior steps have been completed - otherwise, color schemes, powerline, and symbols probably won't work as expected.

If you're curious about what any section of your prompt is doing, try running `starship explain` and it will break your prompt into segments and tell you!

In general though, this is how it works:

> ### Line One
> 
> 1. If the session is elevated, this line is prepended with a lighting bolt
> 1. Display `username@hostname` to tell you who/where this prompt is
> 1. If you're in a git repo, it tells you what branch you're on followed by what remote/branch it is tracking to
> 1. If you're in a git repo and in a detached head state (looking at a commit or tag), it tells you so
> 1. If you're in a git repo and in the midst of an action (cherry picking, rebasing, etc), it tells you so
> 1. If you're in a git repo, it tells you about your current status:
>    - How many commits ahead/behind/diverged/conflicted you are (purple)
>    - How many files have been deleted (red)
>    - How many files have been staged (green)
>    - How many files have been renamed (white)
>    - How many files have been modified (cyan)
>    - How many untracked files have been added (orange)
>
> ### Line Two
> 
> 1. Displays whether or not the last command was successful (green check) or failed (purple X)
>    - NB: In PowerShell, the failed shows up for _PowerShell commands_ which failed in addition to binaries; in Windows PowerShell, only for binaries.
> 1. Displays the current directory
> 1. Displays language information if in a project folder; currently configured for Ruby, Rust, and Go with the default prompt (non-powerline) for dotnet

## Profile Helpers

This section does some session setup for both Windows PowerShell (5.1) and PowerShell (7+). It:

- writes an environment variable, `ISELEVATEDSESSION` if the current shell context is elevated
- Changes the Error output color from red to purple
- Changes the Warning output color to orange (`Blue` is used for orange in the Monokai Spectrum pallete)
- Turns on `gh` autocompletion
- Imports `posh-git` for `git` autocompletion

To use it, copy the contents of `profile_helpers.ps1` to a folder in your user directory (mine is `~/code/profile_helpers.ps1`, which is referenced in the profile file).

## Profile

This section runs the `profile_helpers` script in the current scope before initializing the Starship prompt.
Make sure to modify the path to the helpers script to suit your system.

You'll need to set your prompt for both Windows PowerShell and PowerShell as they are not shared.

```powershell
# Import functions used in both profiles
. '~/code/profile_helpers.ps1'

# Turn on starship! 🚀🚀🚀
Invoke-Expression (&starship init powershell)
```