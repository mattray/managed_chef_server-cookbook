#
# Cookbook:: managed-chef-server
# Recipe:: data_bag_loader
#

dbdir = node['mcs']['data_bags']['dir']
#org_dir = '/etc/opscode/managed/' + organization
#configrb = org_dir + '/config.rb'
#prune = node['mcs']['data_bags']['prune']

data_bag_loader dbdir do
  organization node['mcs']['org']['name']
end

# existing_dbags = {}

# # get existing data bags
# ruby_block 'list existing data bags' do
#   block do
#     list = shell_out("knife data bag list -c #{configrb}").stdout.split
#     list.each do |dbag|
#       existing_dbags[dbag] = {}
#       items = shell_out!("knife data bag show #{dbag} -c #{configrb}").stdout.split
#       items.each do |item|
#         content = JSON.load(shell_out!("knife data bag show #{dbag} #{item} -c #{configrb} --format json").stdout)
#         existing_dbags[dbag][item] = content
#       end
#     end
#     node.run_state['existing_dbags'] = existing_dbags
#   end
# end

# file_dbags = {}
# file_dbags_files = {}
# node.run_state['file_dbags'] = {}
# node.run_state['file_dbags_files'] = {}

# # get list of data bags to manage
# ruby_block 'get list of data bags to manage' do
#   block do
#     Dir.foreach(dbdir) do |dbag|
#       next if ['.', '..'].member?(dbag)
#       file_dbags[dbag] = {}
#       file_dbags_files[dbag] = {}
#       bagdir = dbdir + '/' + dbag
#       Dir.foreach(bagdir) do |itemfile| # get items for each
#         next if ['.', '..'].member?(itemfile)
#         item = JSON.parse(File.read(bagdir + '/' + itemfile))
#         file_dbags[dbag][item['id']] = item
#         file_dbags_files[dbag][item['id']] = itemfile
#       end
#     end
#     node.run_state['file_dbags'] = file_dbags
#     node.run_state['file_dbags_files'] = file_dbags_files
#   end
#   not_if { dbdir.nil? || !Dir.exist?(dbdir) }
# end

# # if we are pruning we are deleting unmanaged data bags and items
# if prune
#   ruby_block 'delete unused data bags' do
#     block do
#       # existing keys not in new, those are deletes
#       deleted_dbags = node.run_state['existing_dbags'].keys - node.run_state['file_dbags'].keys
#       deleted_dbags.each do |dbag|
#         shell_out("knife data bag delete #{dbag} -y -c #{configrb}")
#       end
#     end
#   end

#   ruby_block 'delete unused data bag items' do
#     block do
#       # existing items not in new, those are deletes (and may be in still existing databags)
#       shared_dbags = node.run_state['existing_dbags'].keys & node.run_state['file_dbags'].keys
#       shared_dbags.each do |dbag|
#         deleted_items = node.run_state['existing_dbags'][dbag].keys - node.run_state['file_dbags'][dbag].keys
#         deleted_items.each do |item|
#           shell_out("knife data bag delete #{dbag} #{item} -y -c #{configrb}")
#         end
#       end
#     end
#   end
# end

# # new databags not in existing need to be created
# ruby_block 'create data bags' do
#   block do
#     new_dbags = node.run_state['file_dbags'].keys - node.run_state['existing_dbags'].keys
#     new_dbags.each do |dbag|
#       print "\nCreating data bag #{dbag}"
#       shell_out("knife data bag create #{dbag} -c #{configrb}")
#     end
#   end
#   not_if { node.run_state['file_dbags'].empty? }
# end

# # new data bag items need to be added to existing or new databags
# ruby_block 'add data bag items' do
#   block do
#     # items new or changed from existing, those are from file
#     shared_dbags = node.run_state['file_dbags'].keys & node.run_state['existing_dbags'].keys
#     shared_dbags += node.run_state['file_dbags'].keys - node.run_state['existing_dbags'].keys
#     # shared_dbags += new_dbags # don't forget the new ones
#     shared_dbags.each do |dbag|
#       node.run_state['file_dbags'][dbag].keys.each do |item|
#         # compare existing data bag items with those in the file
#         next if node.run_state['existing_dbags'].key?(dbag) && node.run_state['existing_dbags'][dbag].key?(item) &&
#                 node.run_state['file_dbags'][dbag][item].eql?(node.run_state['existing_dbags'][dbag][item])
#         print "\nAdding file #{dbdir}/#{dbag}/#{node.run_state['file_dbags_files'][dbag][item]} to data bag #{dbag.to_json}"

#         # shell_out("knife data bag from file #{dbag} #{dbdir}/#{dbag}/#{node.run_state['file_dbags_files'][dbag][item]} -c #{configrb}")

#         data_bag "#{organization}:#{dbag}:#{dbdir}/#{dbag}/#{node.run_state['file_dbags_files'][dbag][item]}" do
#           organization organization
#           data_bag dbag
#           item_json "#{dbdir}/#{dbag}/#{node.run_state['file_dbags_files'][dbag][item]}"
#         end

#       end
#     end
#   end
#   not_if { node.run_state['file_dbags'].empty? }
# end
