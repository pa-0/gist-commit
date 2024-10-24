sudo mysql -u root -e "CREATE USER 'sa'@'%' IDENTIFIED BY 'password'";
sudo mysql -u root -e "ALTER USER 'sa'@'%' IDENTIFIED WITH caching_sha2_password BY 'password';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'sa'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"