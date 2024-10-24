pacman -S #reinstall  
pacman -Qm #list AUR packages and packages not from repository  
pacman -Ss #search packages  
cat /var/log/pacman.log | grep -i installed #last installed packages   
cat /var/log/pacman.log | grep -iE 'installed|upgraded' #last upgraded packages    
cat /var/log/pacman.log | grep -iE 'removed' #last removed packages   
pacman -Ql package #list files of installed package  
pacman -Qo FILENAME          #from which local package is file  
pacman -Fl FILENAME          #list remote files 
pacman -F FILENAME           #from which remote package ...
pacman -Fy sync filedatabase #is file ...
pacman -Qi blackarch-wallpaper #show which packages depend on, installed  
pacman -Sii blackarch-wallpaper #show which packages depend on, all  
pacman -Qtd #dropped and orphaned packages  
pacman -Rcuss #remove cascade, recursive, unneeded  
pacman -Qkk #package integrity  
pacman -S lostfiles #files not owned by arch  
pacman -R $pkgname #remove (aur)packages  
git clone REPO; makepkg; sudo pacman -U .pkg.tar.xz #install AUR package  
makepkg -si #update AUR package which has daily builds  
sudo pacman -Syu #update all packages  
asp checkout linux #clone PKGBUILD repo ...
asp update #update repo ... 
git pull # ...
makepkg --nobuild #download and extract sources only
