#!/bin/bash

apt_line="deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main"
source_file="/etc/apt/sources.list.d/ansible.list"
apt_key="93C4A3FD7BB9C367"

ansible_location=`which ansible` > /dev/null
if [ $? -eq 0 ]; then
        echo "ansible already available at: $ansible_location"
        echo "exiting setup"
        exit 1
fi

if [ "$USER" != "root" ]; then
        echo "this needs to be run as root"
        exit 1
fi

if [ ! -f $source_file ]; then
        echo "adding ansible apt source to: ${source_file}"
        echo ${apt_line} >> $source_file
        if [ $? -eq 1 ]; then
                echo "append failed .. running as root?  try to sudo"
                exit 1
        fi
else
        echo "ansible apt source already setup"
fi

# launch dirmngr for apt-key management and allow it to be smart about connecting
# to network pub key services
ps -Aef | grep dirmngr > /dev/null
if [ $? -ne 0 ]; then
  dirmngr --daemon # needed on winboxes to allow apt-key adv to work
fi

apt-key list | grep -w $apt_key 2> /dev/null
if [ $? -eq 0 ]; then
        echo "apt key for ansible missing - adding $apt_key"
  if [ ! -f /tmp/ansible.key ]; then
    curl -o /tmp/ansible.key 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367'
    if [ $? -ne 0 ]; then
      echo 'fetch of ansible key failed'
      exit 1
    fi
  fi
  # apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $apt_key # failes in WLS
        apt-key add /tmp/ansible.key
  if [ $? -ne 0 ]; then
    echo "adding key failed..."
    exit 1
  fi
else
        echo "skipping anisble key setup - already installed"
fi

apt-get update && apt-get install -y ansible