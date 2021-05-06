#
# Cookbook:: managed_chef_server
# Recipe:: default
#

# Chef Server 13 requires license acceptance
include_recipe 'managed_chef_server::_accept_license'

# need the ChefWorkstation for the 'berks' and 'chef' commands
include_recipe 'managed_chef_server::_workstation'

# performance tuning based off of recommendations in https://docs.chef.io/server_tuning.html#large-node-sizes
# deprecated for Chef Infra Server 14
if node['mcs']['chef_server_version'] < 14
  include_recipe 'managed_chef_server::_tuning'
end

# Configure the Chef Server for data collection forwarding by adding the following setting to /etc/opscode/chef-server.rb:
node.default['chef-server']['configuration'] += "data_collector['root_url'] = '#{node['mcs']['data_collector']['root_url']}'\n" if node['mcs']['data_collector']['root_url']
# Add for chef client run forwarding
node.default['chef-server']['configuration'] += "data_collector['proxy'] = #{node['mcs']['data_collector']['proxy']}\n" if node['mcs']['data_collector']['proxy']
# Add for compliance scanning
node.default['chef-server']['configuration'] += "profiles['root_url'] = '#{node['mcs']['profiles']['root_url']}'\n" if node['mcs']['profiles']['root_url']

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
