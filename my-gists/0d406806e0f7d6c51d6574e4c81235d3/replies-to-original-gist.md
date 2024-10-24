### Below are the comments posted in response to the original gist
_(may turn out to be useful)_

#### @codepuncher commented on Sep 20, 2018
You should just be able to set them to start on boot with:

```sh
sudo update-rc.d rsyslog defaults
sudo update-rc.d dbus defaults
sudo update-rc.d cron defaults
sudo update-rc.d atd defaults
sudo update-rc.d atd defaults
sudo update-rc.d dnsmasq defaults
sudo update-rc.d mysql defaults
sudo update-rc.d php7.2-fpm defaults
sudo update-rc.d nginx default
```

#### @valeryan commented on Nov 27, 2018
I will test this in the latest wsl but I don't know that it supports modifying the run class.

#### @valeryan commented on Nov 27, 2018
@codepuncher That does appear to work but any time you open additional bash windows it seems to create separate instances of the services in task manager. 
By having the services started by the script it only creates one instance of the services. Worth testing some more though. Thanks for the tip.

#### @kkm000 commented on Dec 24, 2018
It is possible to launch WSL services with a Windows Task at logon. That decouples them from bash instances. 
The only trick, IIRC, is to allow the startup script to run without asking for a password in /etc/sudoers with a NOPASSWD: prefix.
Never tried the task at boot option, but maybe it can also work?

#### @hendrep commented on Feb 23, 2019
I struggled with my pages sometimes loading and sometimes timing out.
I kept getting upstream timed out (110: Connection timed out) while reading upstream, client: 127.0.0.1,  errors in my valet log.
As per this post, microsoft/WSL#393 (comment), I added fastcgi_buffering off; to my site's Nginx config under .valet/Nginx. Seemed to have solved my issue!