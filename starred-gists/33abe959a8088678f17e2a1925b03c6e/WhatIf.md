# Here is an example of how to include What-If capabilities in a simple PowerShell function

```powershell
function New-Directory {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if ($PSCmdlet.ShouldProcess($Path, 'Create directory')) {
        New-Item -ItemType Directory -Path $Path
    }
}
```

In this example, we define a function called "New-Directory" that creates a new directory at the
specified path. We've included the

```powershell
[CmdletBinding()]
```

attribute at the beginning of
the function definition, which enables a set of common parameters, including -WhatIf.

We've also added the

```powershell
[SupportsShouldProcess()]
```

parameter to the CmdletBinding attribute. This enables the function to support the What-If feature. The $PSCmdlet.ShouldProcess() method is used to determine whether to execute the code or not, based on whether the -WhatIf parameter was used or not.

When the function is called, you can use the -WhatIf parameter to preview the changes that would occur if the function were to run:

```powershell
PS C:\> New-Directory -Path C:\Temp -WhatIf
What if: Performing the operation "Create directory" on target "C:\Temp".
```

This shows that if the New-Directory function were to run, it would create a new directory at C:\Temp. However, because we used the -WhatIf parameter, it only shows us a preview of what would happen, without actually executing the command.

If you were to run the command without the -WhatIf parameter, it would create the directory:

```powershell
PS C:\> New-Directory -Path C:\Temp
PS C:\>
```
