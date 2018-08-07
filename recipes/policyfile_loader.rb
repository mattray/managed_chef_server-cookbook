#
# Cookbook:: managed-chef-server
# Recipe:: policyfile_loader
#

# loads all of the policyfile lock files in a directory into the Chef server

# find the local policyfiles
Dir.foreach(node['mcs']['policyfile-directory']) do |pfile|
  next unless pfile.end_with?('.json')

  # parse the filename, drop the JSON
  pgroup = pfile.sub(/.json$/

  # chef push home policyfiles/beaglebone.lock.json

  log pfile do
    message "Found: #{pfile}"
    level :info
  end
end
