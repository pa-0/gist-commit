sudo apt update
sudo apt-get upgrade
sudo apt-get install \
	curl \
	git \
	man \
	silversearcher-ag \
	ssh \
	rsync \
	tmux \
	tree \
	vim \
	wget
wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install powershell

#after kernal build
sudo apt-get -t buster-backports install \
	btrfs-progs \
	iftop \
	iotop \
	net-tools \
	openvpn \
	resolvconf \
	ufw \
	wireguard
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy