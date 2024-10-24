# Did you know you can install fonts without elevation?

The catch is that they're only available for the duration of your session. They are, however, available in all apps across the system.

Someone asked about how to do it on Facebook this week, and at first, I just pointed them at [the install script for PowerLineFonts](https://github.com/powerline/fonts/blob/master/install.ps1) which loops through all the fonts in a folder and install them.

I've used this more than a few times to install some fonts, including the PowerLine ones, which are great:

```posh
$sa = New-Object -ComObject Shell.Application
$fonts =  $sa.NameSpace("shell:fonts")

foreach($font in Get-ChildItem -Recurse -Include *.ttf, *.otg) { 
    $fonts.CopyHere($font.FullName)
}
```

The problem is that this seems to require you to have administrative rights (it's actually putting the fonts in C:\Windows\Fonts), and this guy didn't have that, and was looking for a way to install the fonts just for a single session. It turns out [there is a Win32 API for that](https://msdn.microsoft.com/en-us/library/dd183326). 

Now, when you see a windows API that simple (it just takes a string), you can just write the `DllImport` yourself. However, if you don't know where to start, there's something even simpler. Look it up on [PInvoke](http://www.pinvoke.net/default.aspx/gdi32.AddFontResource) and you can just copy paste the C# declaration. You just have to call `Add-Type` and specify the type name, and an empty namespace, and make sure that the declaration has `public` on the front. This one looks like this:

```posh
add-type -name Session -namespace "" -member @"
[DllImport("gdi32.dll")]
public static extern int AddFontResource(string filePath);
"@

$null = foreach($font in Get-ChildItem -Recurse -Include *.ttf, *.otg) {
    [Session]::AddFontResource($font.FullName)
}
```

That's all there is to it. It adds the font to your session, and it'll be gone after reboot. 

Technically, you're supposed to call [RemoveFontResource](https://msdn.microsoft.com/en-us/library/dd162922) to unload the fonts, and notify everyone when you've added (or removed) fonts by sending a `WM_FONTCHANGE` broadcast message. That gets a little more complicated, but the whole thing is actually there as the C# code for an executable on that PInvoke page. 

We could map that to PowerShell wrapping Get-ChildItem if we wanted to, and even stick it into a Fonts module ;-)