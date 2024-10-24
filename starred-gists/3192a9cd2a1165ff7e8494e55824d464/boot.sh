#!/bin/bash

/etc/init.d/ssh start

if [ -f /etc/hosts.append ]; then
  grep APPEND /etc/hosts > /dev/null
  if [ $? -eq 0 ]; then
    echo "/etc/hosts already has append content"
  else
    echo "appending /etc/hosts.append to /etc/hosts"
    cat /etc/hosts.append >> /etc/hosts
  fi
fi