### Want to write a Windows batch file that can run anywhere without installation?

- Readable and editable by everyone, without compilation or extra tools (like scriptcs or CS-Script)?
- CMD is too limited for the job (Bash would be nice but isn't easily available on Windows)?
- The PowerShell syntax won't fit in your head?

#### Just use a decent programming language like C#!

Thanks to a few tricks (that I learned from others but forgot the sources) you can inline **`PowerShell`** code in a batch file that in turn inlines **`C#`** code, all with just 4 lines of boilerplate code, and execute it with the passed command-line arguments. Much like a simple .NET Console application.

Your code goes into the `App.Run` method. You can add more methods and classes if needed. Remember to add the necessary using statements at the top of the code. If you're editing this file in Notepad++, manually select the C# language from the menu to get better syntax highlighting.

#### Limitations:

- No IntelliSense, because you usually won't be using Visual Studio to type this (but you could, and paste in your project code here)
- No process return codes, because PowerShell doesn't support this without the `-File` argument which can't be used with a multi-mode file like this
- Short startup delay (half a second on my old Core i7 3770, but that's for all PowerShell scripts)
- .NET Framework 4.x by default; to use the latest .NET version (currently .NET 7):
1. install PowerShell 7.x 
2. Replace <code>%SystemRoot%\System32\WindowsPowerShell\v1.0\\<strong>powershell.exe</strong></code> with <code><strong>pwsh.exe</strong></code> at the beginning of the file. 
 
 >[!NOTE]
 >The startup delay doubles with the new version. You can verify the version with this C# code: 
 >```csharp
 >Console.WriteLine(Environment.Version);
 >```