# Ping()

`Ping()` is a rewrite of [`Ping4()`][1], optimized for continuos pings.

## Example

Ping every second GitHub and place a `ToolTip` in the lower corner of the screen.

```ahk
#Warn
#Persistent

SetTimer PingGitHub, 1000

return ; End of auto-execute

PingGitHub() {
    rtt := Ping("github.com")
    msg := rtt ? "GitHub: " rtt "ms" : "Ping error!"
    ToolTip % msg, % A_ScreenWidth, % A_ScreenHeight, 20
}
```

[1]: https://www.autohotkey.com/boards/viewtopic.php?p=4652#p4652
