#/bin/sh

#
# perform knife ec backup of chef server data
# and compress it for storage locally
#
# Author: Chris Gillings (chris.gillings@fastlane-it.com)
#

BACKUPDIR="/tmp/kitchen/cache/mcs-backups"

# ensure backup directory exists

mkdir -p $BACKUPDIR

RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "Error $RESULT creating backup directory $BACKUPDIR"
   exit $RESULT
fi

# perform knife backup

/opt/opscode/embedded/bin/knife ec backup \
   --with-key-sql \
   --with-user-sql \
   -c /etc/opscode/pivotal.rb \
   $BACKUPDIR/backup > $BACKUPDIR/backup.log 2>&1

RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "knife ec backup failed with error status $RESULT"
   exit $RESULT
fi

# tarball the backup without changing directories

BACKUPFILE="$BACKUPDIR/chef-server-backup-`date +%Y%m%d%H%M`.tgz"

find $BACKUPDIR/backup -printf '%P\0' | \
   tar -C $BACKUPDIR/backup \
       --null --files-from=- \
       -czf $BACKUPFILE

RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "knife ec backup tarball failed with error status $RESULT"
   exit $RESULT
fi

# test backup file for validity
tar xzf $BACKUPFILE > /dev/null 2>&1
RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "knife ec backup tarball failed validation with error status $RESULT"
   exit $RESULT
fi

# update 'latest' link
ln -f -s $BACKUPFILE $BACKUPDIR/chef-server-backup-latest.tgz

# tidy up
rm -rf $BACKUPDIR/backup

# that's all
