sudo apt update
sudo apt-get install mysql-server -y
mysql --version

# https://sac4686.tistory.com/59
# change bind-address to 0.0.0.0
sudo nano  /etc/mysql/mysql.conf.d/mysqld.cnf
sudo netstat -ntlp | grep mysqld

sudo service mysql start
sudo mysql -u root
