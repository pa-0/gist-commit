sudo apt-get remove --purge mysql*

dpkg -l | grep mysql

sudo apt-get remove --purge [filename]

sudo rm -rf /etc/mysql /var/lib/mysql
sudo rm -rf /var/log/mysql
sudo rm -rf /var/log/mysql.*
sudo rm /var/lib/dpkg/info/*
sudo apt-get autoremove
sudo apt-get autoclean
