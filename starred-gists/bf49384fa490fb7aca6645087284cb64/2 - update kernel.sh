user=bob
vers='linux-msft-wsl-5.15.123.1'

sudo apt install bc build-essential flex bison libssl-dev libelf-dev dwarves
git clone --depth 1 --branch 'linux-msft-wsl-5.15.y' 'https://github.com/microsoft/WSL2-Linux-Kernel'

cd WSL2-Linux-Kernel/
cp Microsoft/config-wsl .config
#$diff .config Microsoft/config-wsl
#7c7
#< # Compiler: gcc (Debian 8.3.0-6) 8.3.0
#---
#> # Compiler: x86_64-msft-linux-gcc (GCC) 9.3.0
#10c10
#< CONFIG_GCC_VERSION=80300
#---
#> CONFIG_GCC_VERSION=90300
#12d11
#< CONFIG_CC_CAN_LINK=y
#897d895
#< CONFIG_INET6_TUNNEL=y
#902,904c900,901
#< CONFIG_IPV6_TUNNEL=y
#< CONFIG_IPV6_MULTIPLE_TABLES=y
#< CONFIG_IPV6_SUBTREES=y
#---
#> # CONFIG_IPV6_TUNNEL is not set
#> # CONFIG_IPV6_MULTIPLE_TABLES is not set
#996c993
#< CONFIG_NETFILTER_XT_CONNMARK=y
#---
#> # CONFIG_NETFILTER_XT_CONNMARK is not set
#1797d1793
#< CONFIG_NET_VRF=y
#3323a3320
#>
make -j`nproc`

cp vmlinux "/mnt/c/Users/$user/$vers"
printf '%s\r\n%s' '[wsl2]' 'kernel=C:\\Users\\'"$user"'\\'"$vers" >"/mnt/c/Users/$user/.wslconfig"
#RESTART

vers=`uname -r | sed 's/[+]$//'`
sudo make -j`nproc` headers_install
sudo make -j`nproc` modules_install
sudo rm "/lib/modules/$vers"
sudo ln -s "/lib/modules/$vers+" "/lib/modules/$vers"
sudo cp -r ./ "/usr/src/$vers"
sudo rm "/lib/modules/$vers/"{source,build}
sudo ln -s "/usr/src/$vers" "/lib/modules/$vers/build"
sudo ln -s "/usr/src/$vers" "/lib/modules/$vers/source"