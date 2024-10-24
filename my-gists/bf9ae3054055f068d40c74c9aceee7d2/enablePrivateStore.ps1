# Define credential variables to pass creds securely:
$Pass = "Granger12!" | ConvertTo-SecureString -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PsCredential('WORKGROUP\NetworkAdmin',$Pass)
$Path = "HKLM\SOFTWARE\Policies\Microsoft\Windows\Network Connections\NC_ShowSharedAccessUI"
$StorePath

# Define workstations to execute on:
$PCLIST = Get-Content "C:\PCLIST.txt"

# Create ForEach loop targeting list of workstations:
ForEach ($computer in $PCLIST) {
# Command to execute:
    Invoke-Command -ComputerName $computer -Credential $Creds -Scriptblock {
        New-ItemProperty -Path $Path -Name "NC_ShowSharedAccessUI" -Value "1";
        New-ItemProperty -Path $StorePath -Name "RequirePrivateStoreOnly" -Value "1"
    }
}