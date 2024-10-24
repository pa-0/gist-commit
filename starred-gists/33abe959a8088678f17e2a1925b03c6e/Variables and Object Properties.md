
# <https://www.alkanesolutions.co.uk/2022/09/13/powershell-variables-and-object-properties-in-a-double-quoted-string/>

# It's useful to know how to use PowerShell variables and object properties in a double-quoted string as part of PowerShell'’'s string expansion

# As a simple example we cab expand the $name variable inside the $sentence variable like so

$name = "John"
$sentence = "My name is $name"
Write-Host $sentence

# output

# My name is John

# This is easy enough to grasp. Note that PowerShell expansion does NOT work inside single quotes like so

$name = "John"
$sentence = 'My name is $name'
Write-Host $sentence

# output

# My name is $name

# We can use PowerShell expansion to write the PowerShell version to a variable and output it in a similar way like so

$version = $PSVersionTable.PSVersion
$sentence = "Powershell version is $version"
Write-Host $sentence

# output

# Powershell version is 5.1.19041.1682

# However, if we wanted to inject the PowerShell version directly we can see that the following does not work

$sentence = "Powershell version is $PSVersionTable.PSVersion"
Write-Host $sentence

# output

# Powershell version is System.Collections.Hashtable.PSVersion

# Instead, what we need to do when expanding object properties in PowerShell is to enclose it in $() like so

$sentence = "Powershell version is $($PSVersionTable.PSVersion)"
Write-Host $sentence

# output
# Powershell version is 5.1.19041.1682

# A final alternative is to use the string format (-f) operator like so – here we use placeholders for variable names such as { 0 } { 1 } and { 2 } and after the -f parameter we specify a comma-delimited array of values to substitute in

$sentence = "Powershell version is {0}" -f $PSVersionTable.PSVersion
Write-Host $sentence

# output

# Powershell version is 5.1.19041.1682

# A slightly more complex version might be

$sentence = "Powershell major version is {0} and minor version is {1}" -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
Write-Host $sentence

# output

# Powershell major version is 5 and minor version is 1
