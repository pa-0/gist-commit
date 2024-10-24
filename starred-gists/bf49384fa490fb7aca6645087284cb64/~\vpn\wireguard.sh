#!/bin/bash
DIR=`dirname $(readlink -f "$0")`
DO="$DIR/wireguard/$1.conf"
UNDO="$DIR/wireunguard.conf"

printf '%s\n' \
        '#!/bin/bash' \
        "sudo wg-quick down '$DO'" \
        "rm '$UNDO'" \
>"$UNDO"
chmod +x "$UNDO"
sudo wg-quick up "$DO"