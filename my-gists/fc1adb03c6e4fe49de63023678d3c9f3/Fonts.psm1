add-type -name Session -namespace "" -member @"
[DllImport("gdi32.dll")]
public static extern bool AddFontResource(string filePath);

[DllImport("gdi32.dll")]
public static extern bool RemoveFontResource(string filePath);

[return: MarshalAs(UnmanagedType.Bool)]
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool PostMessage(IntPtr hWnd, int Msg, int wParam = 0, int lParam = 0);
"@

function Get-Font {
    [CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true, HelpUri='http://go.microsoft.com/fwlink/?LinkID=113308')]
    param(
        [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]]
        ${LiteralPath},

        [Parameter(Position=1)]
        [string]
        ${Filter},

        [string[]]
        ${Include},

        [string[]]
        ${Exclude},

        [Alias('s')]
        [switch]
        ${Recurse},

        [uint32]
        ${Depth},

        [switch]
        ${Force},

        [switch]
        ${Name}
    )
    dynamicparam
    {
        try {
            $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
            $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
            if ($dynamicParams.Length -gt 0)
            {
                $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
                foreach ($param in $dynamicParams)
                {
                    $param = $param.Value
                    if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
                    {
                        $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                        $paramDictionary.Add($param.Name, $dynParam)
                    }
                }
                return $paramDictionary
            }
        } catch {
            throw
        }
    }

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $PSBoundParameters['Include'] = "*.fon", "*.fnt", "*.ttf", "*.ttc", "*.fot", "*.otf", "*.mmm", "*.pfb", "*.pfm"

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }

            if($MyInvocation.InvocationName -eq "Add-Font") {
                $scriptCmd = {& $wrappedCmd @PSBoundParameters | Microsoft.PowerShell.Core\ForEach-Object {
                                                                    if([Session]::AddFontResource($_.FullName)) {
                                                                        Write-Verbose "Added Font: $(Resolve-Path $_.FullName -Relative)"
                                                                    }
                                                                    else {
                                                                        Write-Warning "Failed on $(Resolve-Path $_.FullName -Relative)"
                                                                    }
                                                                } }
            } elseif($MyInvocation.InvocationName -eq "Remove-Font") {
                $scriptCmd = {& $wrappedCmd @PSBoundParameters | Microsoft.PowerShell.Core\ForEach-Object {
                                                                    if([Session]::RemoveFontResource($_.FullName)) {
                                                                        Write-Verbose "Removed Font: $(Resolve-Path $_.FullName -Relative)"
                                                                    }
                                                                    else {
                                                                        Write-Warning "Failed on $(Resolve-Path $_.FullName -Relative)"
                                                                    }
                                                                } }
            }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
        $EVERYONE = New-Object IntPtr 0xffff
        $FONTCHANGE = 0x1D
        $NULL = [Session]::PostMessage($EVERYONE, $FONTCHANGE)
    }
    <#
    .ForwardHelpTargetName Microsoft.PowerShell.Management\Get-ChildItem
    .ForwardHelpCategory Cmdlet
    #>
}

Set-Alias Add-Font Get-Font
Set-Alias Remove-Font Get-Font

Export-ModuleMember -Function "Get-Font" -Alias "Add-Font", "Remove-Font"