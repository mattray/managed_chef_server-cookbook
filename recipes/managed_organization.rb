#
# Cookbook:: managed_chef_server
# Recipe:: managed_organization
#

# create the managed Chef organization and user
managed_organization 'create managed Chef server organization and user' do
  organization node['mcs']['org']['name']
  full_name node['mcs']['org']['full_name']
  email node['mcs']['managed_user']['email']
  password node['mcs']['managed_user']['password']
end
