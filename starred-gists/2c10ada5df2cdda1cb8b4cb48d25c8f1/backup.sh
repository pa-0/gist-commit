#!/usr/bin/env bash

printf "*** RSYNC START - %s ***\n" "`date`" >> backup.log

rsync -vaxhR --delete /etc rsync@backups.diesel.net:/volume1/pve >> backup.log
rsync -vaxhR --delete /var/lib/vz rsync@backups.diesel.net:/volume1/pve >> backup.log
rsync -vaxhR --delete /var/spool/cron rsync@backups.diesel.net:/volume1/pve >> backup.log
rsync -vaxhR --delete /var/lib/pve-cluster rsync@backups.diesel.net:/volume1/pve >> backup.log
rsync -vaxhR --delete /root rsync@backups.diesel.net:/volume1/pve >> backup.log

printf "*** RSYNC END - %s ***\n" "`date`" >> backup.log