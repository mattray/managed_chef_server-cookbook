#
# Cookbook:: managed-chef-server
# Recipe:: default
#

# performance tuning based off of recommendations in https://docs.chef.io/server_tuning.html#large-node-sizes
include_recipe 'managed-chef-server::_tuning'

# chef-server install
include_recipe 'chef-server::default'

# run nginx as a non-root user
include_recipe 'managed-chef-server::_nginx'

# restore from a backup if present
chef_server "restore Chef server from backup" do
  tarball node['mcs']['restore']['file']
  action :restore
  only_if { defined?(node['mcs']['restore']['file']) }
end

# create the managed Chef organization and user
managed_organization "create managed Chef server organization and user" do
  organization node['mcs']['org']['name']
  full_name node['mcs']['org']['full_name']
  email node['mcs']['managed_user']['email']
  password node['mcs']['managed_user']['password']
  action :create
end

execute 'verify the chef-server is working as expected' do
  command 'chef-server-ctl test'
  action :nothing
  subscribes :run, 'chef_ingredient[chef-server]'
  not_if { node['mcs']['skip_test'] }
end
