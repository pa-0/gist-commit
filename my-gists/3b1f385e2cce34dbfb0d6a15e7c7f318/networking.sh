curl ifconfig.me #show wan-ip /ua user agent, /all, ...
scp #reads also from .ssh/config
ssh -o "UserKnownHostsFile /dev/null" #don't write to .ssh/known_hosts ...
ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub #ECDSA key fingerprint
2>&1 | grep -v "^Warning: Permanently added" #for surpassing warning ...
vimdiff /etc/php5/cli/php.ini scp://root@remotehost:remoteport//etc/php5/cli/php.ini #vimdiff local vs remotefile  
rsync #can also fetch mail via imap  
curl -o /dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip #command line speed test 
sudo apachectl start #starts apache server  
nc -zv servername 3306 #portscanner ...  
#Connection to servername 3306 port [tcp/mysql] succeeded! ... 
nmap -Pn -sS -p 80 -iR 0 --open #locate random webservers for browsing 
fetchmail #fetch mail via imap
fetchmailconf #fetch mail via imap  
netstat -tulpen #list listening ports 
scp -P 401 root@servername:/* 'somefile' #don't do, copies rootdirectory to remotemachine 
grep . /proc/sys/net/ipv4/tcp_* #tcp-settings
postfix #postfix mail server control program  
iwlist wlan1 scan | grep Channel #scan interface and show busy channels
jnettop #network monitor
netstat #network monitor
iftop #network monitor
iperf #performance monitor
pppd #point to point protocol daemon