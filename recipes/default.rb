#
# Cookbook:: managed_chef_server
# Recipe:: default
#

file '/etc/chef/accepted_licenses/chef_infra_server' do
  only_if { node['chef-server']['accept_license'] }
end

# need the ChefDK for the 'berks' and 'chef' commands
include_recipe 'managed_chef_server::_chefdk'

# performance tuning based off of recommendations in https://docs.chef.io/server_tuning.html#large-node-sizes
include_recipe 'managed_chef_server::_tuning'

# chef-server install
include_recipe 'chef-server::default'

# run nginx as a non-root user
include_recipe 'managed_chef_server::_nginx'

# restore from a backup if present
managed_chef_server_restore 'restore Chef server from backup' do
  tarball node['mcs']['restore']['file']
  not_if { !defined?(node['mcs']['restore']['file']) }
end

execute 'verify the chef-server is working as expected' do
  command 'chef-server-ctl test'
  action :nothing
  subscribes :run, 'chef_ingredient[chef-server]'
  not_if { node['mcs']['skip_test'] }
end
