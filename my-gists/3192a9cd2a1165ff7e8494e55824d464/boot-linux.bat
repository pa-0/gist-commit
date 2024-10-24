REM assumes bash.exe is set to your default WSL environment you want
REM hint: wslconfig /l  # list WSL environments
REM hint: wslconfig /setdefault Ubuntu-18.04  # set default 


REM Script assumes passwordless sudo for a launch script of /boot.sh in the linux system
REM hint: visudo and then add NOPASSWD
REM  
C:\Windows\System32\bash.exe -c "sudo /boot.sh"

REM if you only want 
REM C:\Windows\System32\bash.exe -c "sudo /etc/init.d/ssh start"