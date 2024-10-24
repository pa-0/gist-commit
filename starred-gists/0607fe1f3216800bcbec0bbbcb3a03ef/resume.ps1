# Install ubuntu appx we downloaded earlier
Add-AppxPackage -Path "$env:TEMP\ioopm\Ubuntu.appx"

# This part requires user input
# Username + Password + Exit
ubuntu1804.exe install --root
ubuntu1804.exe run "DEBIAN_FRONTEND=noninteractive sudo apt-get update && sudo apt-get install -y gcc clang libclang-dev lldb emacs25 vim tree make tmux curl astyle zsh linux-tools-common valgrind git libcunit1-dev doxygen xclip global zip unzip openjdk-8-jdk linux-tools-generic cscope cproto gcovr tig htop junit gnuplot graphviz cmake indent ubuntu-desktop"
ubuntu1804.exe run "sudo adduser ioopm --gecos \"\" --disabled-password"
ubuntu1804.exe run "sudo usermod -aG sudo ioopm" 
ubuntu1804.exe config --default-user ioopm
ubuntu1804.exe run "echo \"export DISPLAY=localhost:0.0\" >> ~/.bashrc"

# Cleanup (%temp%/ioopm)
Get-ChildItem -Path "$env:TEMP\ioopm" -Recurse | Remove-Item -force -recurse
Remove-Item "$env:TEMP\ioopm" -Force

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowAllTrustedApps" /d "0"
Set-ExecutionPolicy -ExecutionPolicy AllSigned


# Double check that the resume-task is removed
Get-ScheduledTask -TaskName IOOPMInstallResume | Unregister-ScheduledTask -Confirm:$false