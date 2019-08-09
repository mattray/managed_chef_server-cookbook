#
# Cookbook:: managed-chef-server
# Recipe:: default
#

# need the ChefDK for the 'berks' and 'chef' commands
include_recipe 'managed-chef-server::_chefdk'

# performance tuning based off of recommendations in https://docs.chef.io/server_tuning.html#large-node-sizes
include_recipe 'managed-chef-server::_tuning'

# chef-server install
include_recipe 'chef-server::default'

# run nginx as a non-root user
include_recipe 'managed-chef-server::_nginx'

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
