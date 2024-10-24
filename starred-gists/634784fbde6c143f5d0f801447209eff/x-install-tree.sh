#!/bin/bash
######################################
# Install: Unix/Linux Folder Tree    #
# WTFPL ~ https://centerkey.com/tree #
######################################

# To run this installer:
#     $ curl -s https://centerkey.com/tree/install-tree.sh | bash

echo
echo "Install: Unix/Linux Folder Tree"
echo "==============================="
mkdir -p ~/apps/tree
cd ~/apps/tree
echo "Install folder:"
pwd
curl --remote-name https://centerkey.com/tree/tree.sh
grep "Tree v" tree.sh
chmod +x tree.sh
slink=/usr/local/bin/tree
test -f $slink && echo "slink already exists... not changing"
test -f $slink || ln -sv ~/apps/tree/tree.sh $slink
echo "Installed:"
readlink $slink
echo "In path:"
which tree
echo
