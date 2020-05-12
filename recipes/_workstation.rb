# need the Chef Workstation for the 'chef' command
chef_ingredient 'chef-workstation' do
  action :install
  version node['chef-workstation']['version']
  channel node['chef-workstation']['channel']
  package_source node['chef-workstation']['package_source']
end.run_action(:install)

# this symlink confuses chef-workstation and chef client packages and may
# downgrade/upgrade the chef-client version unintentionally
# https://github.com/mattray/managed_chef_server-cookbook/issues/36
# https://github.com/mattray/managed_chef_server-cookbook/issues/40
link '/bin/chef-client' do
  to '/opt/chef/bin/chef-client'
  only_if { ::File.exist?('/opt/chef/bin/chef-client') }
end
