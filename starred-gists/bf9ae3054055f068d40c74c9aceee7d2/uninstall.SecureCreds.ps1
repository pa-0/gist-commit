# Define credential variables to pass creds securely:
$Pass = "Granger12!" | ConvertTo-SecureString -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PsCredential('WORKGROUP\NetworkAdmin',$Pass)

# Define workstations to execute on:
$PCLIST = Get-Content "C:\PCLIST.txt"

# Create ForEach loop targeting list of workstations:
ForEach ($computer in $PCLIST) {
# Command to execute:
    Invoke-Command -ComputerName $computer -Credential $Creds -Scriptblock {
        $app = Get-WmiObject Win32_Product -ComputerName "localhost" | where { $_.name -eq "Wazuh Agent" }
        $app.Uninstall()
    }
}