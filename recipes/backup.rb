#
# Cookbook:: managed-chef-server
# Recipe:: backup
#

chef_server_backup "schedule Chef server backups" do
  directory node['mcs']['backup']['dir']
  prefix node['mcs']['backup']['prefix']
  minute node['mcs']['backup']['cron']['minute']
  hour node['mcs']['backup']['cron']['hour']
  day node['mcs']['backup']['cron']['day']
  month node['mcs']['backup']['cron']['month']
  weekday node['mcs']['backup']['cron']['weekday']
end
