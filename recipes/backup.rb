#
# Cookbook:: managed_chef_server
# Recipe:: backup
#

managed_chef_server_backup node['mcs']['backup']['dir'] do
  prefix node['mcs']['backup']['prefix']
  minute node['mcs']['backup']['cron']['minute']
  hour node['mcs']['backup']['cron']['hour']
  day node['mcs']['backup']['cron']['day']
  month node['mcs']['backup']['cron']['month']
  weekday node['mcs']['backup']['cron']['weekday']
end
