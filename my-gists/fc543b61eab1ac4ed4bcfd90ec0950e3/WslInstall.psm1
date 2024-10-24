function Add-WslUser {
    <#
        .SYNOPSIS
            Adds a user to a WSL distro
    #>
    [CmdletBinding()]
    param(
        # The distro to add the user to
        [Parameter(Mandatory)]
        $Distribution,

        # The user and password to add
        [Parameter(Mandatory)]
        [PSCredential]$Credential
    )
    # If we were interactive, you could leave off the --disabled-password and it would prompt
    if ($Credential.Password.Length -eq 0) {
        Write-Warning "Creating passwordless user"
        Write-Host "`n>" wsl "-d" $Distribution "-u" root adduser "--gecos" GECOS "--disabled-password" $Credential.UserName.ToLower()
        wsl -d $Distribution -u root adduser --gecos GECOS --disabled-password $Credential.UserName.ToLower()
    } else {
            Write-Host "`n>" wsl "-d" $Distribution "-u" root adduser "--gecos" GECOS $Credential.UserName.ToLower()
        "{0}`n{0}`n" -f $Credential.GetNetworkCredential().Password |
            wsl -d $Distribution -u root adduser --gecos GECOS $Credential.UserName.ToLower()
    }
    Write-Host "`n>" wsl "-d" $Distribution "-u" root usermod "-aG" sudo $Credential.UserName.ToLower()
    wsl -d $Distribution -u root usermod -aG sudo $Credential.UserName.ToLower()
}

function Install-WslDistro {
    <#
        .SYNOPSIS
            Installs a WSL Distribution non-interactively
    #>
    [CmdletBinding(DefaultParameterSetName="Secured")]
    param(
        # The distribution to install
        [Parameter(Position=0)]
        $Distribution = "ubuntu",

        # The default user for this distribution (by default, your user name, but all in lowercase)
        [Parameter(ParameterSetName="Insecure")]
        $Username = $Env:USERNAME.ToLower(),

        [Parameter(Mandatory, ParameterSetName="Secured")]
        [PSCredential]$Credential,

        [switch]$Default
    )
    # Install the distribution non-interactively
    Write-Host "`n>" wsl --install $Distribution --no-launch
    wsl --install $Distribution --no-launch
    Write-Host ">" $Distribution install --root
    &$Distribution install --root

    # Start-Sleep -Milliseconds 1000
    # Write-Host "`n>" wsl --install $Distribution
    # wsl --install $Distribution
    # Start-Sleep -Milliseconds 100
    # get-process $Distribution | stop-process

    # Then create the user after the fact
    if (!$Credential) {
        $Credential = [PSCredential]::new($Username.ToLower(), [securestring]::new())
    }
    Add-WslUser $Distribution $Credential

    # Sets the default user
    if (Get-Command $Distribution) {
        Write-Host $Distribution config --default-user $Credential.UserName.ToLower()
        & $Distribution config --default-user $Credential.UserName.ToLower()
    }

    if ($Default) {
        # Set the default distro to $Distribution
        Write-Host "`n>" wsl --set-default $Distribution
        wsl --set-default $Distribution
    }

    Write-Warning "$Distribution distro is installed. You may need to set a password with: wsl -d $Distribution -u root passwd $($Env:USERNAME.ToLower())"
}