# `SetWindowColor.ahk`

> _Supported starting with Windows 11 Build 22000._


### Description.

Set the color of a window's caption, text, or border.

### Examples.

#### Set a custom color to the active window.

```autohotkey
#requires AutoHotkey v2
#include <SetWindowColor>
SetWindowColor(WinExist("A"), 0xFFFFFF, 0x202020, 0x719CC0)
```

#### Reset the color.

```autohotkey
#requires AutoHotkey v2
#include <SetWindowColor>
SetWindowColor(WinExist("A"), 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
```

<div align=center>

![image](https://gist.github.com/user-attachments/assets/f1592ba0-6290-4518-a3e0-5d981ca047e8)

 </div> 
  
>[!Note]
> ### Color format: BGR

#### Convert BGR to RGB

```autohotkey
RgbToBgr(color) => ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
```

