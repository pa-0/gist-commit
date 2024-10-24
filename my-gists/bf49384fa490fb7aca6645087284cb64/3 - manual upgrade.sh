sudo apt-get install packaging-dev debian-keyring devscripts equivs
#rmadison deluge #deluge | 2.0.3-3 | testing | source, all
echo 'deb-src http://deb.debian.org/debian/ testing main' | sudo tee -a /etc/apt/sources.list
sudo apt update
sudo apt-get install -t buster-backports debhelper


#deluge v2
apt source deluge/testing
cd deluge-*/
sudo mk-build-deps --install --remove
dch --bpo
fakeroot debian/rules binary
dpkg-buildpackage -us -uc
sudo apt install ../deluge{-common,-console,d,-web}_*_*.deb

#NONE OF THE FOLLOWING ARE REQIRED ANYMORE WITH NATIVE v5 KERNEL

#reguires compilation against kernel
git clone --depth 1 --branch 'v0.0.20191226' https://git.zx2c4.com/wireguard-linux-compat
cd wireguard-linux-compat/src
sed -i 's/skb_reset_tc/skb_reset_redirect/' queueing.h
make -j$(nproc)
sudo make install

git clone --depth 1 --branch v1.0.20191226 https://git.zx2c4.com/wireguard-tools
cd wireguard-tools/src -j$(nproc)
make -j$(nproc)
sudo make install


#requires compilation against kernel
sudo apt-get install -t buster-backports libnftnl-dev netbase
apt source iptables/unstable
cd iptables-*/
sudo mk-build-deps --install --remove
dch --bpo
fakeroot debian/rules binary
dpkg-buildpackage -us -uc
sudo apt install ../{iptables,libip*,libx*}_*_*.deb

apt source ufw/unstable
cd ufw-*/
sudo mk-build-deps --install --remove
dch --bpo
fakeroot debian/rules binary
dpkg-buildpackage -us -uc
sudo apt install ../ufw_*_*.deb