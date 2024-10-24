
# Toggles

## Table of contents

* [What are they?](#what-are-they)
* [Basic principle](#basic-principle)
* [Considerations](#considerations)
* [Different implementations](#different-implementations)
* [Arbitrary pair](#arbitrary-pair)
* [Positive and Negative](#positive-and-negative)
* [Arbitrary number of values](#arbitrary-number-of-values)
* [Examples: toggles in hotkeys](#examples-toggles-in-hotkeys)
    * [Conditional directive](#conditional-directive)
    * [Conditional statement](#conditional-statement)
    * [`Hotkey` command](#hotkey-command)

## What are they?

Toggles, as the name implies are a switch for a state. Is generally bound to turn on/off any given functionality. The most common usage is a binary 2-step toggle; non-binary and multiple-step toggles are less common but also seen.

## Basic principle

You have a variable with a boolean value (`1`/`0`, `true`/`false`) and after you toggle it you change its value to the opposite state.

In Layman's terms: if the toggle is active, deactivate it; else *vice versa*.

<details>
    <summary>test.ahk</summary>

```ahk
toggle := false

if (toggle = true)
    toggle := false
else
    toggle := true
```

</details>

## Considerations

* **One toggle per functionality**. If you have multiple functionalities that need the usage of a toggle use a variable for each one, otherwise unintended effects might occur (like one functionality left running and the other not starting).
* **Always initialize the variable**. While this is not forcefully necessary is the right way to do it. If using the [`#Warn`][1] directive an alert will be shown stating that the variable is not initialized, also might be needed to start the toggle in the "on" state.

    * This will show [an alert][2]:

        <details>
            <summary>test.ahk</summary>

        ```ahk
        #Warn

        if (toggle = true)
            toggle := false
        else
            toggle := true
        ```

        </details>

    * This won't:

        <details>
            <summary>test.ahk</summary>

        ```ahk
        #Warn

        toggle := true

        if (toggle = true)
            toggle := false
        else
            toggle := true
        ```

        </details>

## Different implementations

We already checked the "lengthy" method that involves `if`/`else` combination, still, we have the:

* [Ternary Operator][3]:

    <details>
        <summary>test.ahk</summary>

    ```ahk
    toggle := 0

    ; Integer values
    toggle := toggle = 1 ? 0 : 1
    MsgBox % toggle ; Shows 1

    ; Boolean values
    toggle := toggle = true ? false : true
    MsgBox % toggle ; Shows 0
    ```

    </details>

* [Logical NOT][4]\*:

    <details>
        <summary>test.ahk</summary>

    ```ahk
    toggle := false

    toggle := !toggle
    MsgBox % toggle ; Shows 1

    toggle := !toggle
    MsgBox % toggle ; Shows 0
    ```

    </details>

    <sup>*\* Applies to all languages, not just scripting like AutoHotkey or JavaScript.*</sup>

* [Exclusive OR][5] ([XOR][6]):

    <details>
        <summary>test.ahk</summary>

    ```ahk
    toggle := 0

    toggle ^= 1
    MsgBox % toggle ; Shows 1

    toggle ^= 1
    MsgBox % toggle ; Shows 0
    ```

    </details>

## Arbitrary pair

Sometimes values different than `true` and `false` are needed (*eg* `yes`/`no`, `On`/`Off`, `1`/`2`, etc), those can be expressed with:

* A ternary operator:

    <details>
        <summary>test.ahk</summary>

    ```ahk
    toggle = "Off"

    toggle := toggle = "On" ? "Off" : "On"
    MsgBox % toggle ; Shows "On"

    toggle := toggle = "On" ? "Off" : "On"
    MsgBox % toggle ; Shows "Off"
    ```

    </details>

* Or a tuple:

    <details>
        <summary>test.ahk</summary>

    ```ahk
    num := 2

    num := [2,1][num]
    MsgBox % num ; Shows 1

    num := [2,1][num]
    MsgBox % num ; Shows 2
    ```

    </details>

## Positive and Negative

Math is always a welcomed addition, makes it a breeze to swap values between a positive and its negative counterpart (*eg*, `+1`/`-1`):

<details>
    <summary>test.ahk</summary>

```ahk
num := 1

num *= -1
MsgBox % num ; Shows 1

num *= -1
MsgBox % num ; Shows -1
```

</details>

Bonus: display the `+` sign:

<details>
    <summary>test.ahk</summary>

```ahk
num := 1

num *= -1
MsgBox % Format("{:+d}", num) ; Shows -1

num *= -1
MsgBox % Format("{:+d}", num) ; Shows +1
```

</details>

## Arbitrary number of values

When cycling through different values there are many possible options, the most common are:

* Having an array of the values, looping through them, validating on each iteration if we are past the last member, if so, start over.

    <details>
        <summary>test.ahk</summary>

    ```ahk
    sizes := ["s", "m", "l", "xl"]
    sizesPosition := 0 ; Last position

    loop 8
        MsgBox % Cycle(sizes, sizesPosition)
    ; Shows: s, m, l, xl... s, m, l, xl...

    Cycle(obj, ByRef i) {
        if (obj.Count() = i)
            i := 1
        else
            i += 1
        return obj[i]
    }

    /* Compact form:
    Cycle(obj, ByRef i) {
        t := obj.Count()
        return obj[i += i = t ? 1 - t : 1]
    }
    */
    ```

    </details>

* Cycling through numbers starting in `0` or `1`. Again, this relies on math (and the [post-increment operator][7]).

    <details>
        <summary>test.ahk</summary>

    ```ahk
    index0 := 0
    loop 6
        MsgBox % "index0: " CycleFrom0(index0, 3) "`n"
    ; Shows: 0,1,2... 0,1,2...

    index1 := 1
    loop 6
        MsgBox % "index1: " CycleFrom1(index1, 3) "`n"
    ; Shows: 1,2,3... 1,2,3...

    CycleFrom0(ByRef var, total) {
        return var++ := Mod(var, total)
    }

    CycleFrom1(ByRef var, total) {
        return var++ := Mod(var + total - 1, total) + 1
    }
    ```

    </details>

## Examples: toggles in hotkeys

* [Conditional directive](#conditional-directive)
* [Conditional statement](#conditional-statement)
* [`Hotkey` command](#hotkey-command)

### Conditional directive

This example uses <kbd>F1</kbd> to toggle the swapping of the mouse buttons. As recommended, initialize the toggle before the end of [auto-execute][8].

<details>
    <summary>test.ahk</summary>

```ahk
toggle := 0

return ; End of auto-execute

F1::toggle ^= 1

#If toggle
    LButton::RButton
    RButton::LButton
#If
```

</details>

### Conditional statement

The following example will place a `ToolTip` that follows the pointer announcing the current time. It uses a different method for each of the hotkeys.

<kbd>F1</kbd> uses a timer to avoid being blocked by an infinite loop (like the one in <kbd>F2</kbd>).

For <kbd>F2</kbd> to be able to stop and avoid being stuck in the infinite loop, the [#MaxThreadsPerHotkey][9] is needed. Just bear in mind that the directive is positional so it will affect every hotkey declared below.

<details>
    <summary>test.ahk</summary>

```ahk
toggle := 0

return ; End of auto-execute

F1::
    toggle ^= 1
    SetTimer TimeNow, % toggle ? 1 : "Delete"
    if (!toggle)
        ToolTip
return

#MaxThreadsPerHotkey 2
F2::
    toggle ^= 1
    while (toggle)
        TimeNow()
    ToolTip
return

TimeNow() {
    FormatTime now,, h:mm.ss tt
    ToolTip % "It's: " now
}
```

</details>

### `Hotkey` command

Toggling the hotkey itself with native AHK functionality. In this case the <kbd>Space</kbd> will issue a message every time is pressed (you can toggle this with <kbd>F1</kbd>):

<details>
    <summary>test.ahk</summary>

```ahk
Space::MsgBox

F1::Hotkey Space, Toggle
```

</details>

[1]: https://www.autohotkey.com/docs/commands/_Warn.htm] "AutoHotkey Help: #Warn"
[2]: https://user-images.githubusercontent.com/53758552/110897917-f2487300-82c3-11eb-812f-c9ea30598207.png "Undefined Variable"
[3]: https://www.autohotkey.com/docs/Variables.htm#ternary "AutoHotkey Help: Ternary Operator"
[4]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Logical_NOT "Logical NOT (!)"
[5]: https://www.autohotkey.com/docs/Variables.htm#AssignOp "AutoHotkey Help: bitwise-exclusive-or"
[6]: https://en.wikipedia.org/wiki/Exclusive_or "Wikipedia: Exclusive or"
[7]: https://www.autohotkey.com/docs/Variables.htm#IncDec "AutoHotkey Help: \[pre|post\]-increment Operator"
[8]: https://www.autohotkey.com/docs/Scripts.htm#auto "AutoHotkey Help: Auto-execute Section"
[9]: https://www.autohotkey.com/docs/commands/_MaxThreadsPerHotkey.htm "AutoHotkey Help: #MaxThreadsPerHotkey"
