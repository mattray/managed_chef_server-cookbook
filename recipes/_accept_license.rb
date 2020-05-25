# Chef Server 13 requires license acceptance
directory '/etc/chef/accepted_licenses/' do
  recursive true
end

template '/etc/chef/accepted_licenses/chef_infra_server' do
  source 'chef_infra_server.erb'
  mode '0400'
  variables(time: Time.now)
  action :create_if_missing
  only_if { node['chef-server']['accept_license'] }
end
