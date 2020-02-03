#
# Cookbook:: managed_chef_server
# Recipe:: cron
#

# assumes the chef-client is already installed and may be managed by another Chef server

managed_chef_server_cron 'Chef server Chef client cron job' do
  archive node['mcs']['cron']['policyfile_archive']
  minute node['mcs']['cron']['minute']
  hour node['mcs']['cron']['hour']
  day node['mcs']['cron']['day']
  month node['mcs']['cron']['month']
  weekday node['mcs']['cron']['weekday']
end
