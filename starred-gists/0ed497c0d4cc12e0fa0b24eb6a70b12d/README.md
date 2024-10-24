Information:

<https://redd.it/1051mkc>

See the `example.ahk` in this gist.

`Crypt.ahk` was modified to make it `#Warn`-compatible (`Crypt.ahk.patch` file provided for diff)

---

Creates a new encrypted password in the defined path:

```ahk
MasterPassword_Create(Password, Path)
```

Returns the password, asks for the decryption key if necessary:

```ahk
MasterPassword(Path)
```

Clears the password from memory:

```ahk
MasterPassword("")
```

To automatically clear the password:

```ahk
Options := {}
; Options.Inactive := int  ; In minutes
; Options.Lid      := bool ; On lid close
; Options.Lock     := bool ; On lock screen
; Options.Sleep    := bool ; On system sleep
MasterPassword_Clear(Options)
```

Stop and remove auto-clearing

```ahk
MasterPassword_Clear("")
```
