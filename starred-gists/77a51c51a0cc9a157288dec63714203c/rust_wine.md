# Cross-compiling Rust from Linux to Windows using Wine

🔴 Note: this article is obsolete. This cross-compilation direction may just work out of the box. 🔴

## 0. Ensure Rust works on Host

Let's create a dummy project for a test.

```
$ cargo new test
$ cd test/
$ mkdir examples
$ echo 'fn main() { println!("QQQ") }' > examples/q.rs
$ cargo run --example q
   Compiling test v0.1.0 (file:///mnt/raidy/wine/rsmkvparse/test)
     Running `target/debug/examples/q`
QQQ
```

Let's also ensure Wine itself works:

```
$ wine cmd /c 'echo qqq'
qqq
```

## 1. Installing Rust in Wine

* Download the msi package for Rust
        
        $ wget https://static.rust-lang.org/dist/rust-nightly-i686-pc-windows-gnu.msi
        
* Install it

        $ wine msiexec /i rust-nightly-i686-pc-windows-gnu.msi
        
    next, next, next
    
* Compare host and Wine's rustc verions

        $ wine .wine/drive_c/Program\ Files/Rust\ nightly\ 1.4/bin/rustc.exe -vV
        rustc 1.4.0-nightly (fd302a95e 2015-08-27)
        binary: rustc
        commit-hash: fd302a95e1197e5f8401ecaa15f2cb0f81c830c3
        commit-date: 2015-08-27
        host: i686-pc-windows-gnu
        release: 1.4.0-nightly
        
        $ rustc -vV
        rustc 1.4.0-nightly (fd302a95e 2015-08-27)
        binary: rustc
        commit-hash: fd302a95e1197e5f8401ecaa15f2cb0f81c830c3
        commit-date: 2015-08-27
        host: i686-unknown-linux-gnu
        release: 1.4.0-nightly
        
    They do match.
    
## 2. Copy rust library from Wine to your normal prefix

    $ cp -R ~/.wine/drive_c/Program\ Files/Rust\ nightly\ 1.4/bin/rustlib/i686-pc-windows-gnu ~/prefix/lib/rustlib/
    
In your case, both paths may differ. Use `find / -name rustlib` if not sure.

## 3. Create gcc wrapper script

We need MinGW's gcc to link our executables, not hosts's.

```
$ cat > $HOME/gccwrapper << EOF
#!/bin/sh
exec wine '$HOME/.wine/drive_c/Program Files/Rust nightly 1.4/bin/rustlib/i686-pc-windows-gnu/bin/gcc.exe' "\$@"
EOF

$ chmod +x ~/gccwrapper
```

We can't test this wrapper properly although

```
$ echo 'int main(){printf("HW\n");}' > hello.c
$ ~/gccwrapper hello.c -o hello.exe
gcc.exe: error: CreateProcess: No such file or directory
```

Ensure you get something like this anyway.

Maybe you'll also need something like `export WINEPATH='C:\Program Files\Rust nightly 1.4\bin\rustlib\i686-pc-windows-gnu\bin'` in the wrapper script.

On the other hand, we should already be able to invoke rustc for it:

```
$ rustc -C linker=~/gccwrapper  --target i686-pc-windows-gnu examples/q.rs 
$ wine q.exe 
QQQ
```

### 4. Let's specify cargo our wrapper

```
cat >> ~/.cargo/config << EOF
[target.i686-pc-windows-gnu]
linker = "$HOME/gccwrapper"
EOF
```

### 5. Finally, let's build and test our example for Wine

```
$ cargo build --target i686-pc-windows-gnu --example q
   Compiling test v0.1.0 (file:///mnt/raidy/wine/rsmkvparse/test)
$ wine target/i686-pc-windows-gnu/debug/examples/q.exe 
QQQ
```

---

License: CC-Wiki, Created by Vitaly "_Vi" Shukela in 2015 with the help from WindowsBunny from irc.mozilla.org/#rust
