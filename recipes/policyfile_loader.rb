#
# Cookbook:: managed-chef-server
# Recipe:: policyfile_loader
#

# needed for 'chef' commands
include_recipe 'managed-chef-server::_chefdk'

policyfile_loader node['mcs']['policyfile']['dir'] do
  organization node['mcs']['org']['name']
end
