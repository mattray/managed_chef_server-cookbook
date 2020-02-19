#
# Cookbook:: managed_chef_server
# Recipe:: default
#

# Chef Server 13 requires license acceptance
directory '/etc/chef/accepted_licenses/' do
  recursive true
end

template '/etc/chef/accepted_licenses/chef_infra_server' do
  source 'chef_infra_server.erb'
  mode '0400'
  variables(time: Time.now)
  not_if { ::File.exist?('/etc/chef/accepted_licenses/chef_infra_server') }
  only_if { node['chef-server']['accept_license'] }
end

# need the ChefDK for the 'berks' and 'chef' commands
include_recipe 'managed_chef_server::_workstation'

# performance tuning based off of recommendations in https://docs.chef.io/server_tuning.html#large-node-sizes
include_recipe 'managed_chef_server::_tuning'

# chef-server install
include_recipe 'chef-server::default'

# run nginx as a non-root user
include_recipe 'managed_chef_server::_nginx'

# configure data collection with Automate
include_recipe 'managed_chef_server::_data_collector'

execute 'verify the chef-server is working as expected' do
  command 'chef-server-ctl test'
  action :nothing
  subscribes :run, 'chef_ingredient[chef-server]'
  not_if { node['mcs']['skip_test'] }
end
