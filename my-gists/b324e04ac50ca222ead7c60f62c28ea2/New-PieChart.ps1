ipmo wpk

function Get-Color{
    [Windows.Media.Brushes] |
        Get-Member -Static -MemberType Property |
        ForEach { [Windows.Media.Brushes]::$($_.Name) }
}

function Get-Brightness {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [System.Windows.Media.SolidColorBrush]
        $Brush
    )

    Process {
        $sum = 0
        foreach($channel in 'R','G','B') {
            $sum += $Brush.Color.$channel
        }

        $Brush |
            Add-Member -PassThru NoteProperty Brightness ($sum / 255 / 3)
    }
}

function Get-Palette {

    Get-Color |
        Get-Brightness |
        Where { $_.Brightness -gt 0.5 -And $_.Brightness -lt 0.75 }
}

function Get-Total {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Record,
        $CountPropertyName="Count"
    )

    Begin   { $sum = 0 }
    Process { $sum += $Record.$CountPropertyName }
    End     { $sum }
}

function New-PieItem {
    param($Name, $Count)

    New-Object PSObject -Property @{
        Count = $Count
        Name  = $Name
    }
}

function script:New-LegendItems {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Records,
        $script:NameProperty="Name",
        $script:CountProperty="Count"
    )

    Process {
        ForEach($script:record in $Records) {
            New-StackPanel -Orientation Horizontal -Margin 5 {
                New-Border -Background $record.Brush -BorderThickness 1 -BorderBrush Black -Width 10 -Height 10 -Margin 5 -VerticalAlignment Center
                New-TextBlock -Text $record.$CountProperty -VerticalAlignment Center -Margin 5
                New-TextBlock -Text $record.Percentage.ToString("P0") -VerticalAlignment Center -Margin 5
                New-TextBlock -Text $record.$NameProperty.ToString("N") -VerticalAlignment Center -Margin 5
            }
        }
    }
}

function Get-PieChart {
    param (
        $TargetData,
        $Window
    )

    $script:total = $TargetData | Get-Total
    $Palette = Get-Palette

    for($idx = 0; $idx -lt $TargetData.Count; $idx += 1) {
        $TargetData[$idx] |
            Add-Member -PassThru ScriptProperty Percentage {$this.Count / $total} -Force |
            Add-Member NoteProperty Brush $Palette[$idx] -Force
    }

    New-Object PSObject |

        Add-Member -PassThru NoteProperty Window $Window |
        Add-Member -PassThru NoteProperty TargetData $TargetData |

        Add-Member -PassThru ScriptProperty Legend {
            ForEach($script:record in $this.TargetData) {
                New-StackPanel -Orientation Horizontal -Margin 5 {
                    New-Border -Background $record.Brush -BorderThickness 1 -BorderBrush Black -Width 10 -Height 10 -Margin 5 -VerticalAlignment Center
                    New-TextBlock -Text $record.Name -VerticalAlignment Center -Margin 5
                    New-TextBlock -Text $record.Count -VerticalAlignment Center -Margin 5
                    New-TextBlock -Text "$($record.Percentage*100)%" -VerticalAlignment Center -Margin 5
                }
            }
        } |

        Add-Member -PassThru ScriptProperty PieSlices {            
            function New-Point ($x, $y) { New-Object -TypeName 'System.Windows.Point' -ArgumentList $x, $y }

            $size = [Math]::Min($this.Window.ActualWidth, $this.Window.ActualHeight) * .6
            $arcSize = New-Object -TypeName 'System.Windows.Size' -ArgumentList ($size / 2), ($size /2)
            $origin  = New-Point 150 150
            $radius  = $size / 2

            function Convert-ToCartesian($r, $theta) {
                $thetaRadians = $theta * 2 * [Math]::PI
                $x = $origin.X + $r * [Math]::Sin($thetaRadians)
                $y = $origin.Y - $r * [Math]::Cos($thetaRadians)

                return New-Point $x $y
            }

            $theta = 0.0
            $previousRadial = New-Point $origin.X ($origin.Y - $arcSize.Height)

            foreach($item in $this.TargetData) {
                $theta += $item.Percentage
                $nextRadial = Convert-ToCartesian $radius $theta
                $isLargeArc = $item.Percentage -gt 0.5

                $geom = New-StreamGeometry
                $ctx = $geom.Open()
                try {
                    $ctx.BeginFigure($origin, $true, $true)
                    $ctx.LineTo($previousRadial, $true, $false)
                    $ctx.ArcTo($nextRadial, $arcSize, 0, $isLargeArc, 'Clockwise', $true, $false)
                    $ctx.LineTo($origin, $true, $false)
                } finally { $ctx.Close() }

                New-Path -Data $geom -Fill $item.Brush -Stroke Black -StrokeThickness 1

                $previousRadial = $nextRadial
            }
        } | 
        Add-Member -PassThru ScriptProperty Chart {
            param($window)
            
            $rdp    = New-DockPanel -Dock 
            $canvas = New-Canvas -Margin 40
            
            $script:legend = $this.Legend
                        
            $this.PieSlices | % { $canvas.Children.Add($_) | Out-Null }
            $rdp.Children.Add((New-StackPanel {$legend})) | Out-Null
            
            New-DockPanel -Children ($rdp, $canvas)
        }
}

function Update-Chart {
    param($window, $name)
    
    $target = $window | Get-ChildControl $name    
    $target.Children.Clear()
    $target.Children.Add((Get-PieChart $data $target).Chart)
}

$style = @{
    WindowStartupLocation = 'CenterScreen'
    Width  = 450 
    Height = 400 
}

$data = $(
    New-PieItem 'Total Space' 10
    New-PieItem 'Free Space' 70
    New-PieItem 'Unused Space' 20
)

New-Window @style -Show -On_SizeChanged { Update-Chart $window PieChart } {
    New-StackPanel -Name PieChart
}