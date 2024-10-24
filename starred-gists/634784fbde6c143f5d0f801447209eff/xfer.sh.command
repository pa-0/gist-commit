#!/bin/bash
##########################
# Unix/Linux Folder Tree #
##########################

# To make this file runnable:
#     $ chmod +x *.sh.command

banner="Publish tree.sh"
projectHome=$(cd $(dirname $0); pwd)
pkgInstallHome=$(dirname $(dirname $(which httpd)))
apacheCfg=$pkgInstallHome/etc/httpd
apacheLog=$pkgInstallHome/var/log/httpd/error_log
webDocRoot=$(grep ^DocumentRoot $apacheCfg/httpd.conf | awk -F'"' '{ print $2 }')

displayIntro() {
   cd $projectHome
   echo
   echo $banner
   echo $(echo $banner | sed s/./=/g)
   pwd
   chmod +x tree.sh
   ls -l tree.sh
   echo
   }

publishWebFiles() {
   cd $projectHome
   publishFolder=$webDocRoot/centerkey.com/tree
   publish() {
      echo "Publishing:"
      echo $publishFolder
      cp -v tree.sh $publishFolder
      cp -v x-install-tree.sh $publishFolder/install-tree.sh
      echo
      }
   test -w $publishFolder && publish
   }

launchBrowser() {
   cd $projectHome
   url=https://centerkey.com/tree/
   test -w $publishFolder && url=http://localhost/centerkey.com/tree/
   echo "Opening:"
   echo $url
   sleep 2
   open $url
   echo
   }

displayIntro
publishWebFiles
launchBrowser
