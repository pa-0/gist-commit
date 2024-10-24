#!/bin/bash
sudo service dbus start
sudo service cron start
sudo service atd start
sudo service memcached start
sudo service redis-server start
sudo service mysql start
sudo service php7.4-fpm start
sudo service nginx start
bash
