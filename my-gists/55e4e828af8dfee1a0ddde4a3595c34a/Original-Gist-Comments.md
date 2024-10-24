### Comments (may prove useful)

#### [mattfreer](https://gist.github.com/mattfreer) commented [on Feb 7, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1001278#gistcomment-1001278)
In order for this to work you need to specify volume like so:
```sh
docker run -rm -t -i -v $(dirname 𝑆𝑆𝐻𝐴𝑈𝑇𝐻𝑆𝑂𝐶𝐾):(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK ubuntu /bin/bash
```


#### [pda](https://gist.github.com/pda) commented [on May 23, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1233903#gistcomment-1233903)
```sh
docker run --volume $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent ubuntu ssh-add -l
```


#### [runlevel5](https://gist.github.com/runlevel5) commented [on Jun 18, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1248596#gistcomment-1248596)
Wow, I was wondering how this solutions works with socket file share, it wasn't supposed to work though. But then again, now I realise that docker containers share same kernel level with the guest OS. Good tips 👍


#### [elhu](https://gist.github.com/elhu) commented [on Jul 24, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1269386#gistcomment-1269386)
Is there any pre-requisite for the Docker host? My host can connect to a SSH server using private key authentication just fine, but the container fails to find a private key (which makes sense since it doesn't have it) and fallbacks to password authentication...


#### [plasticine](https://gist.github.com/plasticine) commented [on Jul 29, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1272258#gistcomment-1272258)
I can’t see how this would work, given that the permissions on `$SSH_AUTH_SOCK` in the host won’t allow access from the container user? I must be missing something? :/


#### [slmingol](https://gist.github.com/slmingol) commented [on Jul 31, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1273711#gistcomment-1273711)
This exposes the value of the $SSH_AUTH_SOCK (whichiis the path to a socket file on the host) as a volume into the docker container (at the location /ssh-agent). Inside the container you then set the environment variable $SSH_AUTH_SOCK with the path to the volume inside, /ssh-agent). Since this environment variable is now set, ssh-agent -l can make use of it inside the container. When you run these commands inside the docker container you're root and so you have access.


#### [arunthampi](https://gist.github.com/arunthampi) commented [on Aug 1, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1274332#gistcomment-1274332)
If you're running this command in a Vagrant created VM, you might have problems with the file in `$SSH_AUTH_SOCK` being a symlink, so this worked for me:
```sh
docker run -i -t -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ubuntu /bin/bash
```


#### [tobowers](https://gist.github.com/tobowers) commented [on Dec 30, 2014](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1364064#gistcomment-1364064)
Anyone get this to work in boot2docker yet?


#### [penguincoder](https://gist.github.com/penguincoder) commented [on Feb 10, 2015](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1391039#gistcomment-1391039)
+1 [@arunthampi](https://github.com/arunthampi) That works very well in my Vagrant + Docker setup. I was using a Docker container to run Capistrano commands, so I had a few other things. I needed to add a `--env CAP_USER=$CAP_USER` and then in my Vagrant VM `.bashrc` source a file that contained my remote CAP_USER username. 

File `/home/vagrant/.cap_user` contains just `remote-user`. Then in file: `/home/vagrant/.bashrc` I have a line like this:
```shell
    test -f ~/.cap_user && export CAP_USER=$(cat ~/.cap_user) || true
```
I set that file up in the VM using the `Vagrantfile` shell provisioner to copy both files into the VM. Viola. Capistrano deploying happening inside a Docker container.


#### [dts](https://gist.github.com/dts) commented [on Mar 1, 2015](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1403762#gistcomment-1403762)
[@tobowers](https://github.com/tobowers): Works for me on boot2docker on mac, but I have to do it in two steps, SSH into the host VM, then run [@arunthampi](https://github.com/arunthampi)'s code. Like so:
```sh
 $ boot2docker ssh
 $ docker run -i -t -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ubuntu /bin/bash
```
Once you're in to the host VM, you can check out forwarding status with `ssh-add -L`. If you get the publickeys you expect, proceed into the container.


#### [bigeasy](https://gist.github.com/bigeasy) commented [on Mar 31, 2015](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1424725#gistcomment-1424725)
[@dts](https://github.com/dts) You forgot `-A`.
```sh
$ boot2docker ssh -A
$ ssh-add -l
2048 97:f0:e8:b3:c6:cb:2b:06:93:31:f5:a5:c6:0c:22:07 /Users/alan/.ssh/id_rsa (RSA)
$ docker run -i -t -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ubuntu /bin/bash
$ apt-get -q=2 update && apt-get -q=2 install ssh > /dev/null 2>&1
$ ssh-add -l
2048 97:f0:e8:b3:c6:cb:2b:06:93:31:f5:a5:c6:0c:22:07 /Users/alan/.ssh/id_rsa (RSA)
```


#### [andrerocker](https://gist.github.com/andrerocker) commented [on Aug 7, 2015](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1546078#gistcomment-1546078)
[@tobowers](https://github.com/tobowers) On boot2docker Just your home dir is available on boot2docker-vm, maybe if you symlink the ssh-agent socket to $HOME/something this can work.


#### [rosskevin](https://gist.github.com/rosskevin) commented [on Oct 1, 2015](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1586831#gistcomment-1586831)
I'm trying this, but with docker-compose. I was typing a comment, but too much for this gist. Any help is appreciated over on [http://stackoverflow.com/questions/32897709/ssh-key-forwarding-inside-docker-compose-container](http://stackoverflow.com/questions/32897709/ssh-key-forwarding-inside-docker-compose-container)


#### [f3l1x](https://gist.github.com/f3l1x) commented [on Apr 5, 2016](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1742459#gistcomment-1742459)
```sh
docker run --volume $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent ubuntu ssh-add -l
```
Works pretty well!


#### [kynan](https://gist.github.com/kynan) commented [on Oct 23, 2016](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1904338#gistcomment-1904338)
Has anyone managed to use SSH agent forwarding in combination with running the container as a different user? e.g. ...
```sh
docker run -u $(id -u):$(id -g) --volume $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent
```
SSH actually [checks that the effective UID is present in the password database](https://unix.stackexchange.com/a/113871) and fails with `You don't exist, go away!` otherwise.


#### [whistler](https://gist.github.com/whistler) commented [on Oct 27, 2016](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1907993#gistcomment-1907993) • edited 
I get the following error when trying this out. I'm using a mac and have tried this on both docker for mac and docker-machine. I had to first install git on the ubuntu image.
```sh
docker run --volume $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent ubuntu ssh-add -l                             ✹ ✭
Error connecting to agent: Connection refused
```


#### [gautaz](https://gist.github.com/gautaz) commented [on Nov 3, 2016](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1912788#gistcomment-1912788)
[@whistler](https://github.com/whistler), sharing the auth socket is currently not working for docker for mac, see:  [docker/for-mac#410](https://github.com/docker/for-mac/issues/410). It seems there is a work in progress that should be available before the end of November:  [docker/for-mac#483](https://github.com/docker/for-mac/issues/483)


#### [jrolfs](https://gist.github.com/jrolfs) commented [on Dec 23, 2016](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1955674#gistcomment-1955674)
[@gautaz](https://github.com/gautaz) thanks for the heads up!


#### [vladkras](https://gist.github.com/vladkras) commented [on Jul 18, 2017](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2150730#gistcomment-2150730) • edited 
What if I have Windows? How to use `SSH_AUTH_SOCK`? I can clone repo with common git for WIndows, but not inside the container


#### [sylvain261](https://gist.github.com/sylvain261) commented [on Aug 8, 2017](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2170895#gistcomment-2170895)
It would very helpfull to get a clarification on how to share ssh keys when the hots is windows (maybe by a key copy..)


#### [leandrocrs](https://gist.github.com/leandrocrs) commented [on Aug 9, 2017](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2172022#gistcomment-2172022)
[@Sylvain](https://github.com/Sylvain), give a chance to WSL (Windows Subsystem for Linux).


#### [dragon788](https://gist.github.com/dragon788) commented [on Nov 6, 2017](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2249820#gistcomment-2249820)
[@kynan](https://github.com/kynan) if you aren't using a remote user database for your system (eg LDAP/AD) you can map in /etc/passwd read-only so SSH can find your user.

#### [ghost](https://gist.github.com/ghost) commented [on Nov 9, 2017](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2252776#gistcomment-2252776)
Maybe, there is similar way to integrate `gpg` into `docker` container?


#### [tamsky](https://gist.github.com/tamsky) commented [on Aug 4, 2018](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2669342#gistcomment-2669342)
>[@ghost](https://github.com/ghost) asks:
> Maybe, there is similar way to integrate gpg into docker container?

Browsing around, I saw this: [https://github.com/transifex/docker-gpg-agent-forward](https://github.com/transifex/docker-gpg-agent-forward)


#### [marxangels](https://gist.github.com/marxangels) commented [on Mar 4, 2019](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2853944#gistcomment-2853944) • edited 
How if `docker-compose` and `docker-daemon` not in a same machine such as boot2docker?  I want to put this bunch of parameters in the `docker-compose.yaml` instead of typing them every time.


#### [sbussetti](https://gist.github.com/sbussetti) commented [on Jul 8, 2019](https://gist.github.com/d11wtq/8699521?permalink_comment_id=2964596#gistcomment-2964596) • edited 
For anyone who comes across this: This will not work for anyone using Docker for Mac due to os limitations around file socket access. See: [docker/for-mac#410](https://github.com/docker/for-mac/issues/410)


#### [benjertho](https://gist.github.com/benjertho) commented [on Jul 30, 2020](https://gist.github.com/d11wtq/8699521?permalink_comment_id=3398815#gistcomment-3398815)
This works for me for the first shell logon, but fails for successive attempts. My use case is a remote container that has a longer lifespan, usually of a couple weeks. Is there a solution that is robust against the changing of the SSH_AUTH_SOCK target?
```sh
docker run -dit \
	--network host \
	--gpus all \
	--restart unless-stopped \
	--privileged \
	-e "DISPLAY=$DISPLAY" \
	-e "QT_X11_NO_MITSHM=1" \
        -e "$SSH_AUTH_SOCK:/ssh-agent" \
        -e "SSH_AUTH_SOCK=/ssh-agent" \
	-v "$XSOCK:$XSOCK" \
	-v "$HOME/data:/root/data:rw" \
	-v "$HOME/.gitconfig:/root/.gitconfig" \
	--name $NAME $NAME:latest bash
```


#### [jameshopkins](https://gist.github.com/jameshopkins) commented [on Aug 27, 2020](https://gist.github.com/d11wtq/8699521?permalink_comment_id=3433090#gistcomment-3433090)
The [official guidance](https://docs.docker.com/docker-for-mac/osxfs/#ssh-agent-forwarding) works for me, when nothing else has. It's not very well explained, but the bind mount paths are magic values to allow SSH agent forwarding.


#### [GuillermoAndrade](https://gist.github.com/GuillermoAndrade) commented [on Jan 14, 2021](https://gist.github.com/d11wtq/8699521?permalink_comment_id=3593556#gistcomment-3593556)
> -e "$SSH_AUTH_SOCK:/ssh-agent" \

maybe -v here instead of -e ?


#### [timur265](https://gist.github.com/timur265) commented [on Apr 21, 2021](https://gist.github.com/d11wtq/8699521?permalink_comment_id=3713947#gistcomment-3713947) • edited 
Hi everyone. I have the same problem. Has anyone found the solution?  This works for me for the first shell login, but fails for successive attempts
```sh
sudo docker run --restart always --network host --name github-runner -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent -e REPO_URL="$REPO_NAME" -e ACCESS_TOKEN="$ACCESS_TOKEN" myoung34/github-runner:latest
```


#### [conf](https://gist.github.com/conf) commented [on May 24, 2021](https://gist.github.com/d11wtq/8699521?permalink_comment_id=3754794#gistcomment-3754794)
If you're on a mac, the current incantation should be:
```sh
docker run -it --rm -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" debian bash
```


#### [tomdavies](https://gist.github.com/tomdavies) commented [on Aug 31, 2021](https://gist.github.com/d11wtq/8699521?permalink_comment_id=3878388#gistcomment-3878388)
For anyone struggling to get ssh-agent forwarding to work for non-root container users, here's the workaround I came up with, running my entry point script as root, but using socat + su-exec to expose the socket to the non-root user and then run commands as that user:
1.  Add `socat` and `su-exec` to the container in your Dockerfile (you might not need the later if you're not using alpine)
    ```sh
    USER root
    RUN apk add socat su-exec
    # for my use case I need www-data to have access to SSH, so 
    RUN \
        mkdir -p /home/www-data/.ssh && \
        chown www-data:www-data /home/www-data/.ssh/
    ```
2.  In your entry point:
    ```shell
    #!/bin/sh
    # Map docker's "magic" socket to one owned by www-data
    socat UNIX-LISTEN:/home/www-data/.ssh/socket,fork,user=www-data,group=www-data,mode=777 \
        UNIX-CONNECT:/run/host-services/ssh-auth.sock \
        &
    # set SSH_AUTH_SOCK to the new value
    export SSH_AUTH_SOCK=/home/www-data/.ssh/socket
    # exec commands as www-data via su-exec
    su-exec www-data ssh-add -l
    # SSH agent works for the www-data user, in reality you probably have something like su-exec www-data "$@" here
    ```
3.  Run your container as [@conf](https://github.com/conf) states:
    ```sh
    docker run -it --rm -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" name cmd
    ```


#### [unphased](https://gist.github.com/unphased) commented [on Feb 18, 2022](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4070079#gistcomment-4070079)
_shrug_ this: 
```sh
-v "$SSH_AUTH_SOCK:$SSH_AUTH_SOCK" -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK
```
worked for me. The original gist did not.


#### [josepsmartinez](https://gist.github.com/josepsmartinez) commented [on Mar 8, 2022](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4090122#gistcomment-4090122)
[@unphased](https://github.com/unphased) Probably due to the symlink situation, as [@arunthampi](https://github.com/arunthampi) noticed [here](https://gist.github.com/d11wtq/8699521?permalink_comment_id=1274332#gistcomment-1274332). The line the worked for me was 
```sh
docker run -i -t -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ubuntu /bin/bash
````


#### [Paprikas](https://gist.github.com/Paprikas) commented [on Jun 7, 2022](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4192454#gistcomment-4192454) • edited 
[@unphased](https://github.com/unphased)  
```sh
volume $SSH_AUTH_SOCK:/ssh-agent  
```
and 
```sh
ENV SSH_AUTH_SOCK=/ssh-agent 
```
worked for me for years.  But after I've upgraded packages to the latest (ubuntu 22), the agent just stopped working! I mean - ssh-add -l was saying that it does not have access to the agent.  Thank you, your snippet works! Spent the whole day on this issue ))


#### [wirwolf](https://gist.github.com/wirwolf) commented [on Dec 22, 2023](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4804045#gistcomment-4804045)
Check if you use docker from snap. In my Kubuntu 22.04 I remove docker from snap and install using apt and problem is fixed


#### [vokshirg](https://gist.github.com/vokshirg) commented [on Feb 6](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4880073#gistcomment-4880073)
the latest official documentation helped me with docker-compose setup  
[https://docs.docker.com/desktop/networking/#ssh-agent-forwarding](https://docs.docker.com/desktop/networking/#ssh-agent-forwarding)


#### [sourcecodemage](https://gist.github.com/sourcecodemage) commented [on Mar 5](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4971163#gistcomment-4971163)
is there a version of setup for Redhat linux and distributions based on it like CentOS and Rocky?


#### [sourcecodemage](https://gist.github.com/sourcecodemage) commented [on Mar 5](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4971165#gistcomment-4971165)
> the latest official documentation helped me with docker-compose setup [https://docs.docker.com/desktop/networking/#ssh-agent-forwarding](https://docs.docker.com/desktop/networking/#ssh-agent-forwarding)

That seems to be specific to Docker Desktop. What about Colima and/or Podman?


#### [philippkemmeter](https://gist.github.com/philippkemmeter) commented [on Mar 13](https://gist.github.com/d11wtq/8699521?permalink_comment_id=4986048#gistcomment-4986048)
Based on [@tomdavies](https://github.com/tomdavies) post, i created this Dockerfile which uses the USER statement in order to have an unpriviledged container instead of su-exec:
```dockerfile
FROM python:3.11.6-alpine

RUN apk --no-cache add --update \
    socat \
    sudo

RUN addgroup --gid 1001 -S ansible && adduser --uid 1001 -S ansible -G ansible -h /home/ansible
RUN echo 'ansible ALL=(ALL:ALL) NOPASSWD:/usr/local/bin/create-ansible-agent-socket.sh' > /etc/sudoers
RUN echo 'socat UNIX-LISTEN:/home/ansible/.ssh/agent,fork,user=ansible,group=ansible,mode=777 UNIX-CONNECT:/root/.ssh/agent' > /usr/local/bin/create-ansible-agent-socket.sh
RUN chmod +x /usr/local/bin/create-ansible-agent-socket.sh
RUN echo 'sudo /usr/local/bin/create-ansible-agent-socket.sh & SSH_AUTH_SOCK=/home/ansible/.ssh/agent "$@"' > /entrypoint.sh

USER ansible
RUN mkdir -p /home/ansible/.ssh && chown ansible:ansible /home/ansible/.ssh

ENTRYPOINT [/bin/sh, /entrypoint.sh]
```
you run it then with
```sh
docker run -it -u ansible \
    -v "$SSH_AUTH_SOCK":/root/.ssh/agent \
    -e SSH_AUTH_SOCK=/root/.ssh/agent \
    name cmd
```