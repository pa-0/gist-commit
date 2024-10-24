# Create Menu


## Usage

To use it in your own scripts, just load it as module, to make the function available

```ps1
New-Module -Name "Create Menu" -ScriptBlock ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString("https://gist.githubusercontent.com/BananaAcid/b8efca90cc6ca873fa22a7f9b98d918a/raw/Create-Menu.ps1"))) | Out-Null
```

## Example

Loading module example.

```ps1
New-Module -Name "Create Menu" -ScriptBlock ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString("https://gist.githubusercontent.com/BananaAcid/b8efca90cc6ca873fa22a7f9b98d918a/raw/Create-Menu.ps1"))) | Out-Null


$check = Create-Menu no,yes "Want it?" 1

echo ("you " + ($check ? "do" : "do not") + " want it")
```

... More examples in the module, like ...

<img width="370" alt="Bildschirm­foto 2023-01-06 um 15 46 19" src="https://user-images.githubusercontent.com/1894723/211035316-ec6ea332-209b-438a-908d-8d86fb9efdae.png">
