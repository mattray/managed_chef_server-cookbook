#
# Cookbook:: managed_chef_server
# Recipe:: upgrade
#

# Chef Server 13 requires license acceptance
include_recipe 'managed_chef_server::_accept_license'

managed_chef_server_upgrade 'upgrade Chef Infra Server' do
  package_source node['mcs']['upgrade']['package_source']
  only_if { ::File.exist?(node['mcs']['upgrade']['package_source']) }
end
