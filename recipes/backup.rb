#
# Cookbook:: managed-chef-server
# Recipe:: backup
#

backupdir = node['mcs']['backup']['dir']
command = "#{backupdir}/backup.sh"

directory backupdir

# shell script for backup
file command do
  mode '0700'
  content "#/bin/sh
cd #{backupdir}
/opt/opscode/embedded/bin/knife ec backup --with-key-sql --with-user-sql -c /etc/opscode/pivotal.rb backup > backup.log 2>&1
cd backup
tar -czf ../#{node['mcs']['backup']['prefix']}`date +%Y%m%d%H%M`.tgz *
cd ..
rm -rf backup"
end

# schedule backup on a recurring cron job. Override attributes as necessary
cron 'knife ec backup' do
  environment ({ 'PWD' => backupdir })
  command command
  minute node['mcs']['backup']['cron']['minute']
  hour node['mcs']['backup']['cron']['hour']
  day node['mcs']['backup']['cron']['day']
end
