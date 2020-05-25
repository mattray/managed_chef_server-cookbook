#
# Cookbook:: managed_chef_server
# Recipe:: default
#

# Chef Server 13 requires license acceptance
include_recipe 'managed_chef_server::_accept_license'

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

# give everything time to start up
ruby_block 'Wait for the Chef Infra Server to be ready before proceeding' do
  block do
    wait = 0
    while wait < 12 # wait up to 2 minutes, then proceed
      puts '.'
      if shell_out('chef-server-ctl status').stdout.match?('down')
        wait += 1
        shell_out('sleep 10')
      else
        wait = 12
      end
    end
  end
  not_if 'chef-server-ctl status'
end

execute 'verify the chef-server is working as expected' do
  command 'chef-server-ctl test'
  action :nothing
  subscribes :run, 'chef_ingredient[chef-server]'
  not_if { node['mcs']['skip_test'] }
end
