#!/bin/bash

#
# Backs up CP and copies the file to a remote SSH server
#

#
# Based off script originally written by: bfraze@us.checkpoint.com
#

# nice to have a proper environment
source /home/admin/.bash_profile

# set the variables we'll use:
DATE=$(date +%Y%m%d%H%M)
BACKUP_NAME=$(hostname)-$DATE
BACKUP_FILE=${BACKUP_NAME}.tgz
BACKUP_DIR=/var/log/CPbackup/backups
USER=cpbackup
ID=/home/admin/.ssh/id_rsa.cpbackup
HOST=<backup host>
DUMP=<location on $HOST>

set_failed () {
  echo "$2 failed with rc=$1" > failed-$BACKUP_NAME
  scp -q -i $ID failed-$BACKUP_NAME $USER@$HOST:$DUMP/failed-$BACKUP_NAME
  exit $1
}

check_rc () {
  rc=$?
  if [ $rc -ne 0 ]; then
    set_failed $rc "$1"
  fi
}

# start the backup and auto answer
echo y | backup --file $BACKUP_NAME
check_rc backup

# copy the backup file
scp -q -i $ID $BACKUP_DIR/$BACKUP_FILE $USER@$HOST:$DUMP/
check_rc scp

# confirm the remote copy and local copy are
# the same, then delete the local copy
rem=$(ssh -q -i $ID $USER@$HOST "md5sum $DUMP/$BACKUP_FILE | cut -d ' ' -f 1")
loc=$(md5sum $BACKUP_DIR/$BACKUP_FILE | cut -d ' ' -f 1)
if [ $rem == $loc ]; then
  rm -f $BACKUP_DIR/$BACKUP_FILE
  exit 0
else
  set_failed 4 confirmation
fi
