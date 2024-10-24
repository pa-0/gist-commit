Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration

$MainWindow=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"        
        WindowStartupLocation="CenterScreen"
              
        Title="Azure Cloud Explorer" Height="800" Width="800">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="45"/>
            <RowDefinition Height="45"/>            
            <RowDefinition/>
            <RowDefinition/>
        </Grid.RowDefinitions>
        
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="150"/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
                
        <Button Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Margin="5" x:Name="Login" Content="Login"/>
        <Button Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Margin="5" x:Name="Refresh" Content="Refresh" />
        <StackPanel Grid.Row="2" Grid.Column="0" Margin="5">
            <Button Margin="5" x:Name="ShowARMTemplate" Content="Show ARM _Template" Height="45" IsEnabled="False"/>
            <Button Margin="5" x:Name="ShowInPortal" Content="Show In _Portal" Height="45"/>
            <Button Margin="5" x:Name="BrowseWebsite" Content="Browse _Website" Height="45" IsEnabled="False" />            
            <Button Margin="5" x:Name="CopyToClipboard" Content="_Copy to Clipboard" Height="45" />            
        </StackPanel>

        <TreeView x:Name="tv" Grid.Row="2" Grid.Column="1" Grid.ColumnSpan="2" Margin="5"/>
        <TextBox x:Name="outputPane" Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="2" Margin="5" FontFamily="Consolas"
            IsReadOnly="True"
            ScrollViewer.HorizontalScrollBarVisibility="Auto"
            ScrollViewer.VerticalScrollBarVisibility="Auto"
        />
        
    </Grid>
</Window>
'@

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$MainWindow)))
$window.Add_Closing({[System.Windows.Forms.Application]::Exit()})

$tv=$Window.FindName("tv")
$login=$Window.FindName("Login")
$refresh=$Window.FindName("Refresh")
$outputPane=$Window.FindName("outputPane")
$ShowInPortal=$Window.FindName("ShowInPortal")
$BrowseWebsite=$Window.FindName("BrowseWebsite")
$ShowARMTemplate=$Window.FindName("ShowARMTemplate")
$CopyToClipboard=$Window.FindName("CopyToClipboard")

$login.add_Click({
    Login-AzureRmAccount
    Show-Resources 
})

$refresh.add_Click({
    Show-Resources
})

$tv.add_SelectedItemChanged(
{
    $ResourceId=$tv.SelectedItem.Tag
    $ShowARMTemplate.IsEnabled = $true
    if($ResourceId -ne $null) {        
        [System.Windows.Input.Mouse]::OverrideCursor= [System.Windows.Input.Cursors]::Wait
        $properties = Get-AzureRmResource -ResourceId $ResourceId | Select -ExpandProperty Properties  
        $outputPane.Text = $properties | Out-String
        $ShowARMTemplate.IsEnabled = $false
        $BrowseWebsite.IsEnabled = ($properties.MicroService -eq "WebSites")
        $BrowseWebsite.Tag = $properties.HostNames
        [System.Windows.Input.Mouse]::OverrideCursor= $null
    }
}
)

$ShowInPortal.add_click({
    $url = "https://portal.azure.com/#resource/{0}" -f ($tv.SelectedItem.Tag)
    start $url    
})

$BrowseWebsite.add_click({
    start ("http://{0}" -f $BrowseWebsite.Tag)   
})

$ShowARMTemplate.add_click({
    [System.Windows.Input.Mouse]::OverrideCursor= [System.Windows.Input.Cursors]::Wait
    $file = New-TemporaryFile
    $fileName = (Export-AzureRmResourceGroup -ResourceGroupName $tv.SelectedItem.Header -Path $file -Force -IncludeParameterDefaultValue).Path    
    $outputPane.Text = [System.IO.File]::ReadAllText($fileName)
    [System.Windows.Input.Mouse]::OverrideCursor= $null        
})

$CopyToClipboard.add_click({
    Set-Clipboard $outputPane.Text
})

$map = @{
    'Microsoft.Sql/servers'="SQLServer"
    'Microsoft.Sql/servers/databases'="Database"
    'Microsoft.Web/serverFarms'="ServerFarm"
    'Microsoft.Web/sites'="WebSite"    
}

function Show-Resources {
    $tv.Items.Clear()

    $r=Get-AzureRmResource|group resourcegroupname

    $r | % {
        $treeNode = New-Object System.Windows.Controls.TreeViewItem
        $treeNode.Header = $_.Name

        $_.Group | %{
            $node = New-Object System.Windows.Controls.TreeViewItem
            
            $resourceType=$map.($_.ResourceType)
            $node.Header = "[$($resourceType)] $($_.ResourceName)"
            $node.Tag = $_.ResourceId
            $null=$treeNode.Items.Add($node)
        }

        $null=$tv.Items.Add($treeNode)
    }
}

[void]$Window.ShowDialog()
#$app = [Windows.Application]::new()
#$null=$app.Run($window)
