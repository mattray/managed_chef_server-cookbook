#!/bin/sh

#
# perform full backup of chef-server config (and data)

# # Puts the initial backup in the /var/opt/chef-backup directory as a tar.gz file; move this backup to a new location for safe keeping
# execute 'chef-server-ctl backup -y' do
#   only_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/chef-server-core.firstrun") }
# end

# set to "-c" to only backup config
CONFIGONLY=""

BACKDIR="/var/opt/chef-backup/"

CHEFBIN="/bin/chef-server-ctl"

if [ ! -x $CHEFBIN ]; then
   echo "$CHEFBIN not found"
   exit 1
fi

mkdir -p $BACKDIR
if [ ! -d $BACKDIR ]; then
   echo "Cannot create backup directory $BACKDIR"
   exit 1
fi

# do full chef server backup

$CHEFBIN backup -y $CONFIGONLY

RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "Chef server backup failed with error $RESULT"
   exit $RESULT
fi

BACKUPFILE=`ls -1tr $BACKDIR/*.tgz | tail -1`

if [ ! -s $BACKUPFILE ]; then
   echo "Cannot find backup file $BACKUPFILE"
   exit 2
fi

# test backup file for validity
tar xzf $BACKUPFILE > /dev/null 2>&1
RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "chef-server-ctl backup tarball failed validation with error status $RESULT"
   exit $RESULT
fi

ln -f -s $BACKUPFILE $BACKDIR/chef-backup-latest.tgz

exit 0

# that's all
