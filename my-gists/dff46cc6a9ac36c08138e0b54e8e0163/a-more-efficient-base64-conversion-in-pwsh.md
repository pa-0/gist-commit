# Efficient Base64 Conversion in PowerShell

Posted [August 20, 2013](https://mnaoumov.wordpress.com/2013/08/20/efficient-base64-conversion-in-powershell/) 
By [mnaoumov](https://mnaoumov.wordpress.com/author/mnaoumov/)

In a previous [blogpost](https://mnaoumov.wordpress.com/2013/06/20/how-to-reach-unreachable-or-copy-files-to-rdp/) I was converting binary files to/from base64

I used naive straightforward approach

```powershell
[Convert]::ToBase64String($bytes)
[Convert]::FromBase64String($base64String)
```

The problem with this approach is that PowerShell must read the whole file into memory. If you need to convert binary files that are larger in size, this can consume a lot of memory and a lot of time.

A better approach is to read file with chunks and convert the chunks. Due to the nature of base64 conversion, the size of chunks should be a multiplier of 3 when converting binary -> base64 and a multiplier of 4 for the reverse.

Note that we used **`[System.IO.Path]::GetFullPath`** instead of **`Resolve-Path`**, because **`Resolve-Path`** works with existing files only, and we need to deal with non-existent `$TargetFilePath` files. With that approach, when I converted 10mb file it completed within a second, whereas for the naive approach it took hours

**BUT:** 

I realized that **`[System.IO.Path]::GetFullPath`** won’t work properly and we need to use [**`Resolve-PathSafe`**](https://mnaoumov.wordpress.com/2013/08/21/powershell-resolve-path-safe/) approach instead. Code above was updated to reflect that.