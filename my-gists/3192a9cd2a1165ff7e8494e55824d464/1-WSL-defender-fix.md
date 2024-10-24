## Windows Defender/Anti-malware Causing Performance Issues

https://github.com/Microsoft/WSL/issues/1932

https://gist.github.com/ian-p-cooke/4e1713729b3676d2a5eaaf96b99978da

https://medium.com/@rspeets/tip-speed-up-your-wsls-i-o-195781b901b9

Here is the example script provided by ian-p-cooke (updated for Ubuntu18.04)

```PowerShell
$win_user = "ipc"
$linux_user = "ipc"
$package = "CanonicalGroupLimited.Ubuntu18.04onWindows_79rhkp1fndgsc"
$base_path = "C:\Users\" + $win_user + "\AppData\Local\Packages\" + $package + "\LocalState\rootfs"
$dirs = @("\bin", "\sbin", "\usr\bin", "\usr\sbin", ("\home\" + $linux_user + "\.cargo\bin"))
$dirs | ForEach { Add-MpPreference -ExclusionProcess ($base_path + $_ + "\*") }
Add-MpPreference -ExclusionPath $base_path
```

Ruby script to generate the above script automatically based on your own custom path.  Run this inside the Ubuntu WSL and copy-n-paste result into an administrator PowerShell:
```ruby
#!/usr/bin/env ruby

ubuntu = Dir.glob("/mnt/c/Users/*/AppData/Local/Packages/CanonicalGroupLimited.*")
case ubuntu.size
  when 0
    # puts "# ERROR: Unable to detect any Ubuntu WSL /mnt/c/Users/*/AppData/Local/Packages/CanonicalGroupLimited.*"
    target = "ERROR-FINDING-UBUNTU_WSL_PATH"
  when 1
    # puts "# Found a single Ubuntu WSL target: ${ubuntu.first}"
    target = File.basename( ubuntu.first )
  else
    puts "#\n#\n# Found multiple Ubuntu WSL targets"
    ubuntu.each { |t| puts "# #{t}" }
    target = File.basename( ubuntu.first )
    puts "# Using first result: #{target}"
end
puts target

path = ENV['PATH'].split(':').map {|p| "\"#{ p.tr('/',%Q{\\}) }\"" }
puts "

#
# Windows PowerShell command to exclude all linux paths from defender:
#
$win_user = $env:UserName
$linux_user = \"#{ ENV['USER'] }\"
$package = \"#{target}\""

puts '$base_path = "C:\Users\" + $win_user + "AppData\Local\Packages" + $package + "\LocalState\rootfs"'

puts "$dirs = @( #{path.join(", ")} )"

puts '$dirs | ForEach { Add-MpPreference -ExclusionProcess ($base_path + $_ + "\*") }
Add-MpPreference -ExclusionPath $base_path'
```