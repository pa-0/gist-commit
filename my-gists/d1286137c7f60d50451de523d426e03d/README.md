
# `GetUrl()`

It retrieves the URL (protocol included) of any browser via either MSAA framework or UI Automation interfaces.

Testing made with the most used\* browsers as of September 2023 (versions as of October 2023).

<sup>*\* Chrome, Edge, Firefox and Opera ([market share][1] above 1%).*</sup>

It uses the [WinTitle & Last Found Window][2] mechanism, so it receives up to 4 parameters (all optional) as described in the `WinExist()` <sup>[docs][3]</sup> function.

Function signature:

```cpp
url := GetUrl([WinTitle, WinText, ExcludeTitle, ExcludeText])
```

## Examples

* <kbd>F1</kbd> will retrieve the URL from the active window.
* <kbd>F2</kbd> will retrieve the URL of the last found window.
* <kbd>F3</kbd> will retrieve the URL when the browser is not active.

```cpp
#Requires AutoHotkey v2.0

F1:: {
    url := GetUrl("A")
    if (url) {
        MsgBox(url, "Active window URL", 0x40040)
    } else {
        MsgBox("Couldn't retrieve an URL from the active window.", "Error", 0x40010)
    }
}

F2:: {
    WinExist("Mozilla Firefox")
    url := GetUrl()
    if (url) {
        MsgBox(url, "Current URL in Firefox", 0x40040)
    } else {
        MsgBox("Couldn't retrieve Firefox URL.", "Error", 0x40010)
    }
}

F3:: {
    url := GetUrl("ahk_exe firefox.exe")
    if (url) {
        MsgBox(url, "Current URL in Firefox", 0x40040)
    } else {
        MsgBox("Couldn't retrieve Firefox URL.", "Error", 0x40010)
    }
}
```

## Files

Files marked with an asterisk work standalone (*ie*, don't require a library).

* [GetUrl.ahk]\* - Active window only
* [GetUrl1.ahk]\* - Active window only (v1.1)
* [GetUrl_Acc.ahk] - Uses MSAA
* [GetUrl_Acc1.ahk] - Uses MSAA (v1.1)
* [GetUrl_UIA.ahk] - Uses UIAutomation
* [GetUrl_UIA1.ahk] - Uses UIAutomation (v1.1)

Rename to `GetUrl.ahk` if using [libraries of functions][4].

Links to Accessibility libraries:

* [MSAA Lib][5] (maintained by me) for AutoHotkey (v2.0/v1.1).
* [UIAutomation Lib][6] (maintained by thqby) for AutoHotkey v2.0.
* [UIAutomation Lib][7] (maintained by Descolada) for AutoHotkey v2.0 (and v1.1).

[1]: https://en.wikipedia.org/wiki/Usage_share_of_web_browsers#Summary_tables "Wikipedia: Usage Share of Web Browsers"
[2]: https://www.autohotkey.com/docs/misc/WinTitle.htm "AutoHotkey: WinTitle Documentation"
[3]: https://www.autohotkey.com/docs/commands/WinExist.htm "AutoHotkey: WinExist() Documentation"
[4]: https://www.autohotkey.com/docs/Functions.htm#lib
[5]: https://gist.github.com/58d2b141be2608a2f7d03a982e552a71 "Gist: MSAA Lib (Acc.ahk)"
[6]: https://github.com/thqby/ahk2_lib/tree/master/UIAutomation "GitHub: UIAutomation"
[7]: https://github.com/Descolada/UIAutomation "GitHub: UIAutomation"

<!-- markdownlint-disable MD051 -->

[GetUrl.ahk]: #file-geturl-ahk
[GetUrl1.ahk]: #file-geturl1-ahk
[GetUrl_Acc.ahk]: #file-geturl_acc-ahk
[GetUrl_Acc1.ahk]: #file-geturl_acc1-ahk
[GetUrl_UIA.ahk]: #file-geturl_uia-ahk
[GetUrl_UIA1.ahk]: #file-geturl_uia1-ahk

<!-- markdownlint-disable-file MD033 -->
