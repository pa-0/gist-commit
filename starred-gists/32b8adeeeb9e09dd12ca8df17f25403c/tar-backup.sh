#!/bin/bash
# imatefx
# backup.sh <full / inc> <source dir> <snapshot dir> <dest dir> <backup name>
# To restore 1st restore a full backup and then all the incremental backups in order
# tar --extract --gunzip --listed-incremental=/dev/null --file hyppo-home.20090130.master.tar.gz
# tar --extract --gunzip --listed-incremental=/dev/null --file hyppo-home.20090131.tar.gz

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    echo "Make sure all the directories path ends with /"
    echo $0 "<full / inc> <source dir> <snapshot dir> <tar file destination dir> <backup name>"
else

	time_stamp=`date`

	backup_type=$1

	source_dir=$2

	snapshot_dir=$3

	dest_dir=$4

	backup_name=$5

	snapshot_file=$snapshot_dir""$backup_name".snar"

	backup_file=$dest_dir""$backup_name"_`date +%F_%T`.tar.gz"

	if [ -d $source_dir ]; then

		if [ -d $dest_dir ]; then

			if [ -d $snapshot_dir ]; then

				if [ $backup_type == "full" ]; then

					echo "Taking Full Backup from $source_dir with snapshot file $snapshot_file to file $backup_file at $time_stamp "

					tar --listed-incremental=$snapshot_file --level=0 -cpvzf $backup_file  $source_dir

					cp $snapshot_file $snapshot_dir""$backup_name"_`date +%F_%T`.snar"
				elif [ $backup_type == "inc" ]; then

					echo "Taking Incremental Backup from $source_dir to file $backup_file at $time_stamp "

					tar --listed-incremental=$snapshot_file -cpvzf $backup_file  $source_dir

					cp $snapshot_file $snapshot_dir""$backup_name"_`date +%F_%T`.snar"
				else
					echo "Not a valid Backup Type"

				fi
			else
				echo "Snapshot directory is not valid"
			fi
		else
			echo "Destination directory is not valid"
		fi

	else
		echo "Source directory is not valid"
	fi
fi