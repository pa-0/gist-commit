This is just an example on how to extend the Clipboard Helper[^1] class I posted yesterday.

## ClipHistory.ahk[^2] - Clipboard History Manager

By no means is a solution for everyone as is a really minimalist approach and only process/stores plain text.

The inspiration was CLCL[^3] and ClipMenu[^4]/Clipy[^5]. For my personal taste, the only thing left to add would be a small visor of some sort as a preview of the current Clipboard content but I haven't figured out how exactly I want that to look like (and is been like that forever).

It provides a hotkey triggered history menu with up to 99 recent Clipboard contents and up to 9 snippets. It does **not** rely on `^c` to grab the contents of the Clipboard so it will work when Clipboard is modified via application menus and toolbars.

The menu is sorted by most recent usage and ignores duplicates, when retrieving an older item is then placed in the most recent position. There are options to delete entries.

The monitor can be toggled via the menu itself or programmatically if there's need for batch modifications of the Clipboard; it also provides a property to skip custom number of changes from the history.

An advantage is that it can be plugged into any script by simply adding:

```ahk
ClipHist := ClipHistory("options.ini")
```

Here's the object public properties/methods:

```ahk
ClipHist.Monitor           ; Get monitor state
ClipHist.Monitor := <bool> ; Set monitor state
ClipHist.Skip              ; Remaining skips
ClipHist.Skip := <int>     ; Skip next # item from history
ClipHist.Previous()        ; Swap and paste previous entry
ClipHist.Toggle()          ; Toggles monitor state
```

The configuration is stored in an INI file, structure is as follows:

```ini
[CLIPBOARD]
key1 = #v
; Hist Menu

key2 = +#v
; Snips Menu

size = 49
; Max items

path = Clips\
; Path for files

[SNIPPETS]
; snip1 =
; snip2 =
; snip3 =
; snip4 =
; snip5 =
; snip6 =
; snip7 =
; snip8 =
; snip9 =
; Max 9 snips
```

Hope you find it useful, as always any feedback is greatly appreciated.

---

Last update: 2022/06/30

[^1]: https://redd.it/mpf896
[^2]: https://git.io/JilgN
[^3]: https://www.nakka.com/soft/clcl/index_eng.html
[^4]: http://www.clipmenu.com/
[^5]: https://clipy-app.com/