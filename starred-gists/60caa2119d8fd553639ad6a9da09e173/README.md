
# MSAA Library (`Acc.ahk`)

The versions in this Gist have the same\* functionality as the original (found [here][1]). However, it has small modifications. None of them has any meaningful impact but the last one (it helps with performance inside iterations, like when recursing the accessibility tree).

<sup>*\* Plus small fixes, validations here and there, and early return where applicable...*</sup>

**Why?** Because to understand what the code does, I need to be able to read it. The original library is distributed with compactness in mind, neverminding the ability to read the code and learn from it.

Also, the author of the original code base (board's user Sean) did so in a certain way; when it got extended, the contributor (forum's user jethrow) added his coding style making the thing a bit harder to grasp at first sight.

While I did my best trying not to change the library functionality, structure and outline; small bits are different yet, is a 1:1 drop-in replacement.

## Modifications

### `#Warn` compatible

It doesn't trigger warnings for undeclared variables if `#Warn` is enabled (as it should).

### Formatting

Everything was re-written with a consistent coding style, ~~following [this][2] guidelines~~. But more than anything is to keep things as simple as possible; AutoHotkey is an easy language, and there is no need to take away that by adding complex expressions.

### Legacy code

Deprecated syntax was removed and used the recommended instead. While not v2-compatible straightforward, the changes made had compatibility in mind; translating into v2 syntax should be easier now.

**UPDATE:** It was easy all right, as proven by the [small changeset][5].

### `ChildId` as pure number

When talking to the `IAccessible` interface, it expects the `ChildId` parameter to be an integer; AutoHotkey v1.1 can pass integers as strings when they are not the result of an expression.

### ANSI compatibility

`Acc_GetRoleText()` and `Acc_GetStateText()` are Unicode-only now. If you plan on [running this in Windows 98][4] you can't, is safe for XP onwards though.

### `Acc_Location()`

The `Acc_Location()` function bundled with the original library receives as the 3rd parameter a referenced variable while other versions in use return it as a property (for example [here][3], see the note at the end of the answer). Now both are provided as they're not in conflict with each other.

### `Acc_ChildrenByRole()`

The function was replaced because it was a copy of `Acc_Children()` with a simple filter. Rather than duplicated functionality, the filter is applied to the result of `Acc_Children()`.

### `Acc_Get()`

- Small input validations.
- Early return on errors.
- Different error text when sending roles in the path.
- It now re-uses `Acc_Location()`.
- `Parent` is a property and was treated as a method, always throwing an error. Now it makes use of a function already written.

### Performance

`oleacc.dll` is not one of the libraries loaded by default, needs to be explicitly loaded/freed every time `DllCall()` is used. The original library already had this in mind; as an improvement, the address of each function is retrieved statically at load to have the same performance as any *standard* DLL.

## Files

### AutoHotkey v2.0

- [Acc.ahk]

### AutoHotkey v1.1

- [Acc1.ahk]

### v2.0 vs v1.1

- [Acc.diff]

[1]: https://autohotkey.com/boards/viewtopic.php?t=26201 "Acc library (MSAA) and AccViewer download links"
[2]: https://i.imgur.com/xNXy54p.gif "u/anonymous1184: AutoHotkey coding style/guidelines"
[3]: https://autohotkey.com/boards/viewtopic.php?t=56470#p253329 "How to get the full ACC path for control on cursor?"
[4]: https://i.imgur.com/mGY13Vl.gif "¯\\\_(ツ)\_/¯"
[5]: #file-acc-diff

[Acc.ahk]: #file-acc-ahk
[Acc1.ahk]: #file-acc1-ahk
[Acc.diff]: #file-acc-diff
