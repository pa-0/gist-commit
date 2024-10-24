# Getting WSL Working on an Enterprise Machine
The WSL can be installed without the MicrosoftStore. Two things have to happen for this to happen. First, support for WSL must be enabled in Windows and then WSL must be installed.
<br>
<br>


## Requirements
The instructions are aimed at the second version (WSL-2) of the subsystem. Therefore, a Windows 10 version 1903 or later with build 18362 or later is required.
<br>
<br>

## Activating
**Follow the [official instructions](https://docs.microsoft.com/en-us/windows/wsl/install-manual#install-windows-subsystem-for-linux).** 

<br>


>[!caution]
>### STOP BEFORE STEP 6!  Instead, follow the instructions below:

<br>

## 'Side-loading' the Subsystem
Download the desired distro from [Microsoft](https://learn.microsoft.com/en-us/windows/wsl/install-manual#downloading-distributions) (e.g. Ubuntu-20.04):

The instructions there describe the installation process for the default Ubuntu distro; however, this did not work for me on two different systems. Instead, the **.appx** must be unzipped using 7-Zip. Since this file runs every time the system starts, you should save the files anywhere in the `$HOME` directory, as this will ensure your Account has the necessary permissions to access them there. Rename the .appx extension to .zip.  Then, unzip the archive. Execute the included .exe. This starts the installation of the subsystem and finally will ask you to create a username and password for your new Ubuntu virtual machine. This should conclude the first leg of the installation process. You can start the subsystem by using the command:
<br>
<br>

```powershell
Add-AppxPackage C:\wsl\ubuntu_2004\ubuntu
# replace the folder path with the location of your recently unzipped distribution
```

<br>
<br>

>[!TIP]
>### Get the New Windows Terminal
>This can also be installed without the store. Simply download and install the latest `.msixbundle` directly from the releases page of the official repository on [GitHub](https://github.com/microsoft/terminal/releases/latest).
