#
# Cookbook:: managed-chef-server
# Recipe:: legacy_loader
#

# need the ChefDK for the 'berks' command
include_recipe 'managed-chef-server::_chefdk'

# cookbooks
cookbooks_loader node['mcs']['cookbooks']['dir'] do
  organization node['mcs']['org']['name']
end

# environments
environments_loader node['mcs']['environments']['dir'] do
  organization node['mcs']['org']['name']
end

# roles
roles_loader node['mcs']['roles']['dir'] do
  organization node['mcs']['org']['name']
end
