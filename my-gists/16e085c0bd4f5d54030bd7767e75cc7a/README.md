## Ini Class in AutoHotkey (version 2)

>Include this script in your AHK Library to make handling (reading / writing / syncing data between) `ini` configuration files and AHK scripts a breeze

### Introduction

I've seen lots of ini-to-object functions over the years here and there, I've even done some myself, but I always wanted more. What do I want? I want things to be done by themselves, rather than me having to go back and forth keeping tabs on when/what/where to read and when/what/where to write.


What if I told you that you only need ***a single line***\* to load a `.ini` file as an object and keep that file synchronized to each change you make to the object?
<br/><sup><em>* Besides the dependency, let's not get ahead of ourselves...</em></sup><br/>

Given that `D:\test.ini` has the following data:

```ini
[GENERAL]
option1=value number 1
second-option=val2
```

You can load it like this:

```autohotkey
Conf := Ini("D:\test.ini")
```
And anything you change from that object (using the standard AHK object interface[^1]) is synchronized to the file. Really, that's it... that's why is automatic. Now here comes the magic (well, is not; but sounds better than the boring technical jargon).

You don't need to call any method/function or do anything other than modify the actual object.
```autohotkey
object.property.key := value
; File > Section > Key = Value
```
So for example, if you want to change the value of the key `option1` from `value number 1` to `value #1` you only need to do the following:
```autohotkey
Conf.GENERAL.option1 := "value #1"
```
And to change the other key from `val2` to `value #2`:
```autohotkey
Conf.GENERAL["second-option"] := "value #2"
```
Now if you open the file you'll find this:
```ini
[GENERAL]
option1=value #1
second-option=value #2
```
### What else?

Since is an object, you can do everything you can do with a standard AHK object:
```autohotkey
MsgBox 0x40, test.ini, % "Total sections: " Conf.Count()
```
Not just the values, but the sections too:
```autohotkey
MsgBox 0x40, [GENERAL], % "Keys in the section: " Conf.GENERAL.Count()
```
You can add new keys:
```autohotkey
Conf.GENERAL.opt3 := "value #3"
```
And will reflect immediately in the file:
```ini
[GENERAL]
option1=value #1
second-option=value #2
opt3=value #3
```
You can empty:
```autohotkey
Conf.GENERAL.opt3 := ""
```
Or delete:
```autohotkey
Conf.GENERAL.Delete("opt3")
```
Add more sections:
```autohotkey
Conf.Other := {a:"AAA", b:"BBB"}
Conf.Test := {}
Conf.Test[1] := "one"
```
So, the file looks like this:
```ini
[GENERAL]
option1=value #1
second-option=value #2
opt3=value #3
[Other]
a=AAA
b=BBB
[Test]
1=One
```
Or get rid of them:
```autohotkey
Conf.Delete("Test")
```
You can iterate:
```autohotkey
for key,val in Conf.GENERAL
    MsgBox 0x40,, % key " → " val "`n"
```
And all that fun stuff, whatever you can do with a standard object you can do with an `Ini` object. Period.

### How?

By hooking into the `__Set()` method to write to disk when appropriate. To do this, it is needed for the property to be inaccessible. That is accomplished with `Object_Proxy` which the only thing it does is *proxy* the object contents (pardon the redundancy) into an internal container. From there, the `__Get()` method retrieves what's being asked and `__Set()` writes to the object and the disk.

`Object_Proxy` is the base object for `Ini_File` and `Ini_Section`. `Ini_File` is just a container for any number of `Ini_Section` instances; one instance per section in the file. Those instances have the reference to the file path and the name of the section they represent.

That's why each section knows where they correspond (if you ever want to handle multiple `.ini` files and/or use a shorthand for the sections):
```autohotkey
xFile := Ini("D:\x.ini")
x := xFile.Section

yFile := Ini("D:\y.ini")
y := xFile.Section
```
In the example above, referencing the whole file is not required to have a reference to the section, and still each update will go to where it should.

### Extra functionality

Updates to the file are done as soon as the object changes, but there are instances where this is not desired. For example, if the object needs to be inside an iteration that will modify the values many times; that in turn will result in an unwanted number of disk writes (which is bad for storage health):
```autohotkey
loop 1000000
    Conf.GENERAL.option1 := A_Index
```
This is a trivial example, but it's enough to demonstrate the need for modifying the automatic synchronization nature of the object:
```autohotkey
Conf.GENERAL.Sync(false) ; Pause automatic synchronization of the section
loop 1000000
    Conf.GENERAL.option1 := A_Index
Conf.GENERAL.Sync(true) ; Resume automatic synchronization of the section
```
And if the changes happen on more than a section, the whole file can be paused from syncing:
```autohotkey
Conf.Sync(false) ; Pause automatic synchronization to the file
loop 1000000 {
    Conf.SECTION_A.option1 := A_Index
    Conf.SECTION_B.option1 := A_Index
}
Conf.Sync(true) ; Resume automatic synchronization to the file
```
Now since the updates weren't automatically written to disk we need to do it manually... to dump the contents of the object to the file you need to use the `.Persist()` method in either the sections affected or for the whole file (depending on what you paused):
```autohotkey
Conf.GENERAL.Persist() ; Just the section
Conf.Persist() ; All the sections in the file
```
### Wrapping

It's not magic but at least is automatic and the simplest way of working with `.ini` files I can think of.

I know the inner workings are poorly explained but honestly, I'm not sure where to start as this encompasses different parts (mostly OOP which can be seen as an "advanced" topic). If someone needs a bit of explaining on one of the parts, just ask... gladly, I'll try to make sense. With that being said, the code footprint is very small and concise, intended to be easily followed.

Even if you don't need to understand how it works, the point is that: *"it just works"* 

You only need to drop the files in a library[^2] and pass as the first parameter to the `Ini()` function the path of your configuration file. The second **optional** parameter is a boolean that controls whether the synchronization should be automatic right from the start.
```autohotkey
Ini(Path, Sync) ; - Path: required, .ini file path.
                ; - Sync: optional, defaults to `true`.
.Sync()         ; - Get synchronization status.
.Sync(bool)     ; - Set synchronization status.
                ;   - `true`: Automatic
                ;   - `false`: Manual through `.Persist()`
.Persist()      ; - Dump file/section values into the file.
```
The files can be found on this gist[^3].

---

Last update: 2024/09/15

[^1]: https://www.autohotkey.com/docs/objects/Object.htm
[^2]: https://www.autohotkey.com/docs/Functions.htm#lib
[^3]: https://gist.github.com/737749e83ade98c84cf619aabf66b063