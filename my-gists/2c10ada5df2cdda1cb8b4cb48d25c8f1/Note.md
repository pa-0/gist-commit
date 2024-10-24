## Overview

Function of each script:
1. Installs Discord Dark Theme
2. Mutes Proxmox subscription notice
3. Creates backups and uploads to Synology NAS using `rsync` over SSH

Schedule with crontab entry for root user on node:

```shell
@daily /bin/bash /root/backup.sh >/dev/null 2>&1
```