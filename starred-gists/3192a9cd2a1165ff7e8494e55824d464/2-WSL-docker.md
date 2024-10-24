Getting Docker for Windows accessable in WSL.  

https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly

## Step 1: Install Docker for Windows

* Make sure to open Docker for Windows Settings
  * Check `Expose daemon on tcp://localhost:2375 without TLS'

## Step 2: Install WSL (Ubuntu 18.04)

## Step 3: Install Docker in the WSL 
From within Ubuntu do normal install for Docker from their repository:
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

Fast steps:
```
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
$ sudo usermod -aG docker $USER
```

<details>

Manual steps:
    
```
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io  # just to be sure legacy docker stuff isn't around

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
sudo apt-get update

sudo apt-get install docker-ce

sudo usermod -aG docker $USER
```

</details>

## Step 4: Install Docker-Compose in the WSL 
https://github.com/docker/compose/releases/

```
export DOCKER_COMPOSE_VERSION=1.23.2
sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
     -o /usr/local/bin/docker-compose \
     && sudo chmod +x /usr/local/bin/docker-compose
```

## Step 5: Configure WSL to Connect to Docker for Windows

Add the following to `.bashrc` in WSL
```
export DOCKER_HOST=tcp://localhost:2375
```

The quick way of doing that
```
echo export DOCKER_HOST=tcp://localhost:2375 >> ~/.bashrc
```

### Step 6: Verify

Close the WSL bash window and re-open it.
* `groups` should list docker as a group in your user now
* `docker info` should list details.  
  * Permission denied error means you didn't get in docker group.  
  * Unable to connect likely means `DOCKER_HOST` not set or Docker for Windows service is not actually running yet.
