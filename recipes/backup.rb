#
# Cookbook:: managed-chef-server
# Recipe:: backup
#

backupdir = node['mcs']['backup']['dir']
command = "#{backupdir}/backup.sh"

directory backupdir

# shell script for backups
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

# schedule backups on a recurring cron job. Refer to the README for further customization
cron 'knife ec backup' do
  environment ({ 'PWD' => backupdir })
  command command
  minute '*/5'
  hour '*'
  day '*'
end
