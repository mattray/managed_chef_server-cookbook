#
# Cookbook:: managed-chef-server
# Recipe:: backup
#

bdir = node['mcs']['backup']['dir']
command = "#{bdir}/backup.sh"

directory bdir

# shell script for backups
cookbook_file command do
  mode '0700'
  source 'backup.sh'
  owner 'root'
  group 'root'
  action :create
end

# schedule backups on a recurring cron job. Refer to the README for further customization
cron 'knife ec backup' do
  # environment ({ 'PWD' => bdir })
  command command
  minute '*/5'
  hour '*'
  day '*'
end

#####################################

cdir = '/var/opt/chef-backup/'
cmd = '/root/chef-server-backup.sh'

directory cdir

# shell script for backups
cookbook_file cmd do
  mode '0700'
  source 'chef-server-backup.sh'
  owner 'root'
  group 'root'
  action :create
end

# schedule backups on a recurring cron job. Refer to the README for further customization
cron 'chef-server-ctl backup' do
  # environment ({ 'PWD' => cdir })
  command cmd
  minute '27'
  hour '4'
  day '*'
end
