"$([System.IO.Path]::GetFileNameWithoutExtension($script:MyInvocation.MyCommand.Name))_$(Get-Date -format "yyyyMMddhhmmss").log"
"$([System.IO.Path]::GetFileNameWithoutExtension($script:MyInvocation.MyCommand.Name)).log"
"$([System.IO.Path]::GetFileNameWithoutExtension($script:MyInvocation.MyCommand.Name))-$((Get-Date -format MMM).ToUpper()).log"