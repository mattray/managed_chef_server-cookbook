resource_name :managed_chef_server_backup
provides :managed_chef_server_backup

property :directory, String, name_property: true
property :prefix, String, default: 'chef-server-backup-'
property :minute, String, default: '*'
property :hour, String, default: '*'
property :day, String, default: '*'
property :month, String, default: '*'
property :weekday, String, default: '*'

action :create do
  backup_dir = new_resource.directory
  command = "#{backup_dir}/backup.sh"

  directory backup_dir

  # shell script for backup
  file command do
    mode '0700'
    content "#/bin/sh
cd #{backup_dir}
PATH=$PATH:/opt/opscode/embedded/bin /opt/opscode/embedded/bin/knife ec backup --with-key-sql --with-user-sql -c /etc/opscode/pivotal.rb backup > backup.log 2>&1
cd backup
cp -r #{node['mcs']['managed']['dir']} chef_managed_orgs
tar -czf ../#{new_resource.prefix}`date +%Y%m%d%H%M`.tgz *
cd ..
rm -rf backup"
  end

  cron "knife ec backup #{backup_dir}" do
    environment('PWD' => backup_dir)
    command command
    minute new_resource.minute
    hour new_resource.hour
    day new_resource.day
    month new_resource.month
    weekday new_resource.weekday
  end
end
