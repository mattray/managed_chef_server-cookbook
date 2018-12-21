#
# Cookbook:: managed-chef-server
# Recipe:: data_bag_loader
#

# get existing data bags # built-in search commands exist for these
# knife data bag list (options)
# get existing items
# knife data bag show BAG [ITEM] (options)

# find items to upload
# if prune
# remove items not present
# knife data bag delete BAG [ITEM] (options)
# upload data bag items
# knife data bag from file BAG FILE|FOLDER [FILE|FOLDER..] (options)

# loads all of the policyfile lock files in a directory into the Chef server
# chef install base.rb     # generates base.lock.json
# chef export base.rb . -a # generates base-VERSION.tgz
# chef push-archive POLICY_GROUP base-VERSION.tgz -c config_file --debug

# require 'chef'

# # Setup connection to Chef Server
# Chef::Config.from_file('/.chef/knife.rb')
# rest = Chef::ServerAPI.new(Chef::Config[:chef_server_url])

# # Fetch data bag
# data_bag = rest.get_rest("/data/#{data_bag_name}")


dbdir = node['mcs']['data_bags']['dir']
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'

unless dbdir.nil?
  Dir.foreach(dbdir) do |dbag|
    next if ['.', '..'].member?(dbag)
    puts dbag
    # knife data bag list -c /etc/opscode/managed/config.rb
    # does the data bag already exist?
    # no -> create
    # read in JSON files from each directory


  end
end
#     next unless pfile.end_with?('.lock.json')

#     # parse the JSON file, get the revision ID
#     plock = JSON.parse(File.read(policydir + '/' + pfile))
#     revision = plock['revision_id']
#     policyname = plock['name']
#     short_rev = revision[0, 9]
#     # match the right policyfile archive based on name in lock file
#     filename = policydir + '/' + policyname + '-' + revision + '.tgz'

#     # push the archive to the policygroup under the policy name
#     execute "chef push-archive #{policyname} #{filename}" do
#       command "chef push-archive #{policyname} #{filename} -c #{configrb}"
#       # add a guard to check if chef show-policy indicates the policy is already installed
#       not_if "chef show-policy #{policyname} -c #{configrb} | grep '* #{policyname}' | grep #{short_rev}"
#     end
#   end
# end
