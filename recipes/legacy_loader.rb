#
# Cookbook:: managed_chef_server
# Recipe:: legacy_loader
#

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
