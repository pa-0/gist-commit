# apt 패키지 정보 최신화
sudo apt update && sudo apt upgrade -y

#######################################################
# mysql 설치
sudo apt install mysql-server -y
mysql --version

sudo systemctl status mysql
