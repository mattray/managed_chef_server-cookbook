#
# Cookbook:: managed_chef_server
# Recipe:: data_bag_loader
#

data_bag_loader node['mcs']['data_bags']['dir'] do
  organization node['mcs']['org']['name']
  prune node['mcs']['data_bags']['prune']
end
