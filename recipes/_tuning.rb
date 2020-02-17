#
# Cookbook:: managed_chef_server
# Recipe:: _tuning
#
# private recipe for performance tuning based off of recommendations in
# https://docs.chef.io/server_tuning.html#large-node-sizes
# http://irvingpop.github.io/blog/2015/04/20/tuning-the-chef-server-for-scale/
# https://getchef.zendesk.com/hc/en-us/articles/207465126-Large-Nodes-opscode-solr-max-field-length

# Available Memory
# From the docs:
# The default value for opscode_solr4['heap_size'] should work for many organizations,
# especially those with fewer than 25 nodes. For organizations with more than 25
# nodes, set this value to 25% of system memory or 1024, whichever is smaller.
# For very large configurations, increase this value to 25% of system memory or
# 4096, whichever is smaller. This value should not exceed 8192.
#
# Interpretation: use 1/4 memory and cap at 8GB unless it's already set
total_mem = node['memory']['total'][0..-3].to_i / 1024
if node['mcs']['opscode_solr4']['heap_size']
  solr_heap_size = node['mcs']['opscode_solr4']['heap_size']
else
  solr_heap_size = total_mem / 4
  solr_heap_size = 8192 if (total_mem / 4) > 8192
end

# Large Node Sizes
# not touching yet
# opscode_erchef['max_request_size']
# opscode_solr4['max_field_length']

# postgresql
# To handle the heavy write load on large clusters, it is recommended to tune the
# checkpointer per [https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server]
# postgresql['checkpoint_segments'] = 64
# postgresql['checkpoint_completion_target'] = 0.9
# log all of the queries that took longer than 1000ms to complete
# postgresql['log_min_duration_statement'] = 1000

# chef-server configuration settings
node.default['chef-server']['configuration'] += <<-EOS
opscode_solr4['heap_size'] = #{solr_heap_size}
postgresql['checkpoint_completion_target'] = 0.9
postgresql['checkpoint_segments'] = 64
postgresql['log_min_duration_statement'] = 1000
EOS

# Next, configure the Chef Server for data collection forwarding by adding the following setting to /etc/opscode/chef-server.rb:
node.default['chef-server']['configuration'] += "data_collector['root_url'] = '#{node['mcs']['data_collector']['root_url']}'\n" if node['mcs']['data_collector']['root_url']
# Add for chef client run forwarding
node.default['chef-server']['configuration'] += "data_collector['proxy'] = #{node['mcs']['data_collector']['proxy']}\n" if node['mcs']['data_collector']['proxy']
# Add for compliance scanning
node.default['chef-server']['configuration'] += "profiles['root_url'] = '#{node['mcs']['profiles']['root_url']}'\n" if node['mcs']['profiles']['root_url']
