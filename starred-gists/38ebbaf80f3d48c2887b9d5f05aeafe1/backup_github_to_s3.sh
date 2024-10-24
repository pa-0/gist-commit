#!/bin/bash

DATE=$(date "+%Y-%m-%d")
GITHUB_OWNER=CHANGEME
BACKUPS_DIR=/tmp/backups
TAR_FILE=github-repos-$DATE.tar.gz
S3_BUCKET=s3://github-offsite-backup
AWS_CMD=/usr/local/bin/aws

# Creates a directory if it doesn't exist
# $1: dir path
create_dir() {
	if [ ! -d $1 ]; then
		mkdir $1
	fi
}

# Clones a repo locally
# $1: git repo name
# $2: owner name
# $3: backups dir
clone_repo() {
	# Change to backups dir
	cd $3

	# Remove repo dir
	rm -rf $1

	# Clone the repo with GitHub Personal Token
	git config --global credential.helper cache
        git config --global credential.https://github.com.username $USERNAME
	git config --global credential.https://github.com.password $USERTOKEN
	git clone https://github.com/foo/repository.git

	# Change to the repo dir
	cd $1

	# Fetch all branches
	git fetch origin
}

# Get a list of GitHub repos that are not forks and clones them
# $1: owner name
# $2: backups dir
clone_owners_repos() {

	# Get an array of repo names
	REPOS=( $( curl -s  https://api.github.com/users/$1/repos |  jq -r '.[] | select( .fork == false ) | .name' ) )

	# Loop through each repo name and clone it locally
	for i in "${REPOS[@]}"
	do
		clone_repo $i $1 $2 # repo name, owner name, backups dir
	done
}

# Create archive of all the repos
# $1: backups dir
# $2: TAR file name
create_tarchive() {
	cd $1
	touch $2
	tar czfv $2 .
}

# Stick is up in S3
# $1: backups dir
# $2: file name
# $3: S3 bucket
copy_file_to_s3() {
	cd $1
	$AWS_CMD s3 cp $2 $3
}

cleanup() {
	cd $1
	rm *.gz
}

# Run all the commands
create_dir $BACKUPS_DIR
clone_owners_repos $GITHUB_OWNER $BACKUPS_DIR
create_tarchive $BACKUPS_DIR $TAR_FILE
copy_file_to_s3 $BACKUPS_DIR $TAR_FILE $S3_BUCKET
# TODO Here add awscli command to set backup expiration rule
cleanup $BACKUPS_DIR
