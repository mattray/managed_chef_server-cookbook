#
# Cookbook:: managed_chef_server
# Recipe:: restore
#

include_recipe 'managed_chef_server::default'

# restore from a backup if present
managed_chef_server_restore 'restore Chef server from backup' do
  tarball node['mcs']['restore']['file']
  not_if { !defined?(node['mcs']['restore']['file']) }
end
