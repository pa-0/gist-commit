
# Auto-Clickers

## Toggle + Click & Hold (loop)

```ahk
cps := 30

return ; End of auto-execute

F1::Hotkey LButton, Toggle

~LButton::
    wait := 1000 // cps
    while (GetKeyState("LButton", "P")) {
        Click
        Sleep % wait
    }
return
```

## Toggle + Click & Hold (timer)

```ahk
cps := 30
toggle := 0

return ; End of auto-execute

F1::toggle ^= 1

#If (toggle)
    LButton::SetTimer Clicker, % 1000 // cps
    LButton Up::SetTimer Clicker, Off
#If

Clicker() {
    Click
}
```

## Click to toggle

```ahk
cps := 30
toggle := 0

return ; End of auto-execute

~LButton::SetTimer Clicker, % (toggle ^= 1) ? 1000 // cps : "Delete"

Clicker() {
    Click
}
```

## Double-Click to toggle

```ahk
cps := 30
toggle := 0

return ; End of auto-execute

~LButton::
    if (A_PriorHotkey = A_ThisHotkey && A_TimeSincePriorHotkey < 200)
        SetTimer Clicker, % (toggle ^= 1) ? 1000 // cps : "Delete"
return

Clicker() {
    Click
}
```
