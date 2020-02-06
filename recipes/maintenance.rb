#
# Cookbook:: managed_chef_server
# Recipe:: maintenance
#

# Use knife-tidy to remove stale nodes?
# https://github.com/chef-customers/knife-tidy

# Use the chef clean-policy-revisions subcommand to delete orphaned policy
# revisions to Policyfile files from the Chef server. An orphaned policy revision
# is not associated to any policy group and therefore is not in active use by any
# node. Use chef show-policy --orphans to view a list of orphaned policy revisions.
# execute 'chef clean-policy-revisions'

# Use the 'chef clean-policy-cookbooks' subcommand to delete cookbooks that are
# not used by Policyfile files. Cookbooks are considered unused when they are not
# referenced by any policy revisions on the Chef server.
