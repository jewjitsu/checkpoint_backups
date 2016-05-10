[check_cp_backup]: #check_cp_backup

# Check Point backups
Skeleton for automated backups of Check Point gateways and management servers.  The backup files should be scheduled to run weekly.  If you are using Nagios, [check_cp_backup] can be used to ensure that backups are being created.

## Backup files
##### `mds-backup-script.sh`
Use this for taking an mds_backup of a Provider-1 server.  It is better to use take an mds_backup instead of a full system backup because mds_backup can be restored on any hardware, as long as the version of Check Point is the same as the bakcup.  A full system backup can only be restored to hardware identical to that on which the backup was taken.
##### `backup-script.sh`
Use this for taking backups of gateways.  I used the regular backup here because it is much more likely to restore to the same type of hardware.

## Nagios check
##### `check_cp_backup`
This is best used with NRPE.  It requires a list of all hostnames expected to be creating backups.
