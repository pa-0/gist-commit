
# Universally Unique Lexicographically Sortable Identifier

Canonical Spec: <https://github.com/ulid/spec>

## `ULID()`

- By default operates in monotonic mode.
- `ULID()` is an alias of `ULID.Monotonic()`.
- Use `ULID.Random()` for non-monotonic mode.

## `ULID.DecodeTime()`

- Decodes the date component of an ID.

## Examples

```ahk
ULID.Monotonic()   ;           ├─ Sequential ─┤
ULID(946684799000) ; 00VHNCZA0RDNAV6EEZZ39ZJJ30
ULID(946684799000) ; 00VHNCZA0RDNAV6EEZZ39ZJJ31
ULID(946684799000) ; 00VHNCZA0RDNAV6EEZZ39ZJJ32
                   ; ├─ Date ─┤

ULID.Random()             ;           ├─── Random ───┤
ULID.Random(946684799000) ; 00VHNCZA0R0C2EZT1HJF682WGX
ULID.Random(946684799000) ; 00VHNCZA0R8KTKPFTW2DRTV8GD
ULID.Random(946684799000) ; 00VHNCZA0RMBY4YRRTATJH3WPR
                          ; ├─ Date ─┤

ts := ULID.DecodeTime("00VHNCZA0RCQXAP2B8G3DF054X")
; > 946684799000 > Fri, Dec 31, 1999 23:59:59 (GMT)
```
