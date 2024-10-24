# System.Math

self-delete the script without asking for confirmation:

```powershell
Remove-Item -Path $MyInvocation.MyCommand.Path -Force
```

```PowerShell
<#
The Math class contains various basic math operations
You can execute methods like round a value
Another operation is square root
It even contains fields like Pi
#>

System.TimeZoneInfo
# The TimeZoneInfo class contains information about time zones on the system. You can use it to do things like look up time zones
[TimeZoneInfo]::GetSystemTimeZones()

# You can also convert a DateTime object to another time zone
$Date = Get-Date
$TimeZoneInfo = [TimeZoneInfo]::GetSystemTimeZones() | Where-Object Id -Eq 'Chatham Islands Standard Time'

System.UriBuilder
# The UriBuilder class is used to compose URIs without string concatenation. It ensures that you can produce valid URIs without having to worry about back slashes and encoding

$Builder = [UriBuilder]::new()
$Builder.Host = "www.google.com"
$Builder.Scheme = "https"
$Builder.Port = 443
$Builder.UserName = "adam"
$Builder.Password = "SuperSecret"
$Builder.Uri.AbsoluteUri

System.Collections.ArrayList
# The ArrayList class is actually used within the PowerShell engine a little bit and you'll see it show up occasionally. It's a useful class for quickly adding items to an array rather than the += operator

# If you're collecting many thousands of items, you may want to use an array list instead of an array
$ArrayList = [System.Collections.ArrayList]::new()
1..1000 | ForEach-Object { $ArrayList.Add($_) } | Out-Null
$ArrayList

System.ComponentModel.Win32Exception
# The Win32Exception is a good utility class for deducing what a Win32 error may mean. Try casting an exception code to the exception class to see the description of the code
[System.ComponentModel.Win32Exception]0x00005

System.IO.FileSystemWatcher
# The FileSystemWatcher class can be used to watch for changes to the file system. You can define filters for types of changes and also file extensions

# This example creates a file system watcher that watches the desktop for text files being created
$FileSystemWatcher = [System.IO.FileSystemWatcher]::new("C:\users\adamr\desktop", "*.txt")
$FileSystemWatcher.IncludeSubDirectories = $false

Register-ObjectEvent $FileSystemWatcher Created -SourceIdentifier FileCreated -Action {
    $Name = $Event.SourceEventArgs.Name
    $Type = $Event.SourceEventArgs.ChangeType
    Write-Host "'$Name' = $Type"
}

System.IO.Path
# The Path class is handy for inspecting, creating and dealing with cross-platform paths

# Unlike Join-Path, the Path class can including more than two paths when joining them

# It's also useful because it works cross-platform and will create paths that work on Unix and Windows systems

# It also helps when trying to determine whether a path is relative or absolute

System.IO.StreamReader
# Many types in .NET will return a stream. Streams are typically used when reading large data sets or data that isn't all available at once. The StreamReader class is helpful for translating these streams into strings. This is particularly useful when reading web request bodies in Windows PowerShell

try
{
    Invoke-RestMethod <http://localhost:5000/throws>
}
catch
{
    [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
}

System.Net.Dns
# The Dns class is useful for invoking the DNS client from .NET. You can use it to resolve IP Address and host names

System.Net.IPAddress
# The IPAddress class is useful for dealing with IPv4 and IPv6 addresses. You can use it to parse and inspect addresses

$Address = [System.Net.IpAddress]::Parse("127.0.0.1")
$Address.AddressFamily

System.Reflection.Assembly
# The Assembly class can be used to load assemblies from the file system or even from base64 strings encoded in the PowerShell script

System.Runtime.InteropServices.RuntimeInformation
# Since PowerShell is now cross-platform, it's useful to understand the platform that the script is running within. There are some variables available like $IsLinux and $IsWindows to determine this information but this class provides even more info

System.Security.SecureString
# The SecureString class is commonly used with PSCredential. It's not considered secure, especially on Unix systems, but it's still used quite often

# SecureString has a bit of a strange API and you need to append characters to it to produce a new one
$SS = [System.Security.SecureString]::new()
"Hello!".ToCharArray() | ForEach-Object { $SS.AppendChar($_) }

System.Text.Encoding
# The Encoding class is useful when dealing with conversion between the Roman alphabet and other alphabets. It’s also great for emojis

# You can also decode byte arrays to text
$Bytes = [System.Text.Encoding]::Ascii.GetBytes("Hello!")
[System.Text.Encoding]::Unicode.GetString($Bytes)

System.Text.StringBuilder
# The StringBuilder class can be used to create dynamic strings without much overhead. Strings in .NET are immutable which means that lot's of resources are required to perform string operations

# You can use the methods of the this class to quickly perform operations like concatenations

# See the below performance differences between standard string concatenation and string concatenation with StringBuilder

Measure-Command {
    $Str = ""
    for($i = 0; $i -lt 10000000; $i++)
    {
        $Str += "Str-{0}" -f $_
    }
    $Str
}

# Did not return after 30 minutes

Measure-Command {
    $SB = [System.Text.StringBuilder]::new()
    for($i = 0; $i -lt 10000000; $i++)
    {
        $SB.AppendFormat("Str-{0}", $i)
    }
    $SB.ToString()
}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 9
Milliseconds      : 960
Ticks             : 99602440
TotalDays         : 0.000115280601851852
TotalHours        : 0.00276673444444444
TotalMinutes      : 0.166004066666667
TotalSeconds      : 9.960244
TotalMilliseconds : 9960.244

# While basic concatenation will show about a 20% improvement with StringBuilder, if you use something like the script above, where formatting is involved, you'll notice an immense improvement
```
