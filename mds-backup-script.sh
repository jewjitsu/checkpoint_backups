#!/bin/bash

# This script automates the process of:
# --running an mds_backup
# --transferring the backup off-box

# need to have a proper environment
source /home/admin/.bash_profile

# set the variables we'll use:
DATE=$(date +%Y%m%d%H%M)
BACKUP_NAME=$(hostname)-$DATE
BACKUP_FILE=${BACKUP_NAME}.tgz
BACKUP_DIR=/var/log/mdsbackup
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

# create backup environment
mkdir -p $BACKUP_DIR
check_rc "create backup dir"
cd $BACKUP_DIR

# run the backup
mds_backup -b -i -l
check_rc mds_backup

# tar the backup
tar czvf $BACKUP_DIR/$BACKUP_FILE *
check_rc tar

# copy the backup file
scp -q -i $ID $BACKUP_DIR/$BACKUP_FILE $USER@$HOST:$DUMP/
check_rc scp

# confirm the remote copy and local copy are
# the same, then delete the local copy
rem=$(ssh -q -i $ID $USER@$HOST "md5sum $DUMP/$BACKUP_FILE | cut -d ' ' -f 1")
loc=$(md5sum $BACKUP_DIR/$BACKUP_FILE | cut -d ' ' -f 1)
if [ $rem == $loc ]; then
  rm -rf $BACKUP_DIR
  exit 0
else
  set_failed 4 confirmation
fi
