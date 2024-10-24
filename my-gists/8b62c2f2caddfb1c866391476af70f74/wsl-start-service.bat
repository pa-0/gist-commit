@echo off
wsl -u root -- service mysql start
wsl -u root -- service redis-server start
