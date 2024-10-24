<# : 
@echo off & setlocal & set __args=%* & %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command Invoke-Expression ('. { ' + (Get-Content -LiteralPath ""%~f0"" -Raw) + ' }' + $env:__args) & exit /b %ERRORLEVEL%
#> Add-Type @'
// ========== BEGIN C# CODE ==========
using System;

public class App
{
	public static void Run(string[] args)
	{
		// Write your code here...
		// Don't forget to add the necessary using statements above.
		// This is a simple example:
		Console.WriteLine(".NET version: " + Environment.Version);
		Console.WriteLine("Arguments: " + string.Join(", ", args));
		// Process return codes are not supported by PowerShell with this method.
	}
}
// ========== END C# CODE ==========
'@; [App]::Run($args)
