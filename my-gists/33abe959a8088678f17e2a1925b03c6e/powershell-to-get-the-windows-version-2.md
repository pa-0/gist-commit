# Using PowerShell to Get the Windows Version

<https://adamtheautomator.com/powershell-to-get-the-windows-version-2/>

- [Using PowerShell to Get the Windows Version](#using-powershell-to-get-the-windows-version)
  - [Selecting Specific Properties to Get the Windows Version](#selecting-specific-properties-to-get-the-windows-version)
  - [Retrieving the Windows Version via the System.Environment Class](#retrieving-the-windows-version-via-the-systemenvironment-class)

Before taking on complex stuff with PowerShell, start with the basics, like getting your system information. With PowerShell, you can quickly get the Window version via the systeminfo command.

Open your PowerShell, and run the following command to get detailed information about your system, including the operating system (OS) version.

```powershell
.\\systeminfo
```

Below, you can see detailed information about the OS, including the current version number, 10.0.19044 N/A Build 19044.

## Selecting Specific Properties to Get the Windows Version

Great! You have just retrieved detailed system information. But if you look closely, the command is short, yet the output seems a lot.

If you only want specific property values, the Get-ComputerInfo command is one of the quickest methods of getting specific system information, like your Windows version.

Run the below to get the Windows version, product name, and version of Windows Kernel and your system hardware’s Operating Hardware Abstraction (OHA).

Below, piping the Select-Object command to the Get-ComputerInfo command lets you retrieve only select properties.

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayerVersion
```

## Retrieving the Windows Version via the System.Environment Class

The System.Environment class also has a property called OSVersion, which contains information about the current OS.

Run the following command to call the OSVersion.Version property from the System.Environment class. The double colon (::) symbol is used to call static methods from a class.

```powershell
[System.Environment]::OSVersion.Version
```

As you can see below, the output displays the OSVersion information as follows:
| PROPERTY | VALUE | DESCRIPTION                                                                                                                                                                                                                                                                                                                               |
| -------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Major    | 10    | Stands for Windows version 10 (Windows 10).                                                                                                                                                                                                                                                                                               |
| Minor    | 0     | There are two types of Windows releases, major and minor. Major releases are the "big" updates like the Creator update, and minor releases are smaller cumulative updates.                                                                                                                                                                |
| Build    | 19044 | The number used to check the Windows version. In this case, it is 1909. The code name for this version is 21H2 <https://learn.microsoft.com/en-us/windows/release-health/release-information#historyTable_1>, which stands for Windows 10 November 2019 Update and is the eighth major update to Windows 10, released on November 12, 2019. |
| Revision | 0     | Denotes a sub-version of the build.                                                                                                                                                                                                                                                                                                       |
