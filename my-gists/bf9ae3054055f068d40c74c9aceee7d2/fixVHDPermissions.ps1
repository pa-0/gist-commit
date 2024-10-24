#Import the NTFSSecurity Module, if not available, prompt to download it
If ((Get-Module).Name -notcontains 'NTFSSecurity'){
    Write-Warning "This script depends on the NTFSSecurity Module, by MSFT"
        if ($PSVersionTable.PSVersion.Major -ge 4){
            Write-Output "This script can attempt to download this module for you..."
            $DownloadMod = Read-host "Continue (y/n)?"

            if ($DownloadMod.ToUpper() -like "Y*"){
                find-module NTFSSecurity | Install-Module
                }
                else{
                #User responded No, end
                Write-Warning "Please download the NTFSSecurity module and continue"
                break
            }

        }
        else {
            #Not running PowerShell v4 or higher
            Write-Warning "Please download the NTFSSecurity module and continue"
            break
        }
    }
    else{
    #Import the module, as it exists
    Import-Module NTFSSecurity

    }

$VMs = Get-VM
ForEach ($VM in $VMs){
    $disks = Get-VMHardDiskDrive -VMName $VM.Name
    Write-Output "This VM $($VM.Name), contains $($disks.Count) disks, checking permissions..."

        ForEach ($disk in $disks){
            $permissions = Get-NTFSAccess -Path $disk.Path
            If ($permissions.Account -notcontains "NT Virtual Mach*"){
                $disk.Path
                Write-host "This VHD has improper permissions, fixing..." -NoNewline
                 try {
                      Add-NTFSAccess -Path $disk.Path -Account "NT VIRTUAL MACHINE\$($VM.VMId)" -AccessRights FullControl -ErrorAction STOP
                     }
                catch{
                       Write-Host -ForegroundColor red "[ERROR]"
                       Write-Warning "Try rerunning as Administrator, or validate your user ID has FullControl on the above path"
                       break
                     }

                Write-Host -ForegroundColor Green "[OK]"

            }

        }
}

