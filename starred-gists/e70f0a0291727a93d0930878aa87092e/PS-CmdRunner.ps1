# Load necessary .NET libraries
Add-Type -AssemblyName PresentationFramework, WindowsBase

# XAML definition
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Posh Runner" Height="300" Width="400">
    <Grid>
        <Label Content="PS Cmd:" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
        <TextBox Name="PSCmdTextBox" HorizontalAlignment="Left" Margin="70,10,0,0" VerticalAlignment="Top" Width="250"/>
        <Button Content="RUN" HorizontalAlignment="Right" Margin="0,10,10,0" VerticalAlignment="Top" Width="60" Name="RunButton"/>

        <DataGrid Name="ResultDataGrid" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,50,10,10">
            <DataGrid.Columns>
                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>
                <DataGridTextColumn Header="Status" Binding="{Binding Status}" Width="*"/>
            </DataGrid.Columns>
        </DataGrid>
    </Grid>
</Window>
"@

# Read the XAML content and create a WPF window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get references to the controls
$runButton = $window.FindName("RunButton")
$psCmdTextBox = $window.FindName("PSCmdTextBox")
$resultDataGrid = $window.FindName("ResultDataGrid")

# Button click event
$runButton.Add_Click({
        $command = $psCmdTextBox.Text
        if (-not [string]::IsNullOrEmpty($command)) {
            try {
                $results = Invoke-Expression $command
                $resultDataGrid.ItemsSource = $results
            }
            catch {
                [System.Windows.MessageBox]::Show("Error executing command: $_", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            }
        }
    })

# Show the WPF window
$window.ShowDialog()
