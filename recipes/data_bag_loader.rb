#
# Cookbook:: managed-chef-server
# Recipe:: data_bag_loader
#

dbdir = node['mcs']['data_bags']['dir']
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'
prune = node['mcs']['data_bags']['prune']

# get existing data bags
existing_dbags = {}
list = `knife data bag list -c #{configrb}`.split
list.each do |dbag|
  existing_dbags[dbag] = {}
  items = `knife data bag show #{dbag} -c #{configrb}`.split
  items.each do |item|
    content = `knife data bag show #{dbag} #{item} -c #{configrb} --format json`
    existing_dbags[dbag][item] = eval(content)
  end
end

# get list of data bags to manage
file_dbags = {}
file_dbags_files = {} # file associated with the data bag items
unless dbdir.nil?
  Dir.foreach(dbdir) do |dbag|
    next if ['.', '..'].member?(dbag)
    file_dbags[dbag] = {}
    file_dbags_files[dbag] = {}
    bagdir = dbdir + '/' + dbag
    Dir.foreach(bagdir) do |itemfile| # get items for each
      next if ['.', '..'].member?(itemfile)
      item = JSON.parse(File.read(bagdir + '/' + itemfile))
      file_dbags[dbag][item['id']] = item
      file_dbags_files[dbag][item['id']] = itemfile
    end
  end
end

# if we are pruning we are deleting unmanaged data bags and items
if prune
  # existing keys not in new, those are deletes
  deleted_dbags = existing_dbags.keys - file_dbags.keys
  deleted_dbags.each do |dbag|
    execute "knife data bag delete #{dbag}" do
      command "knife data bag delete #{dbag} -y -c #{configrb}"
    end
  end
  # existing items not in new, those are deletes
  shared_dbags = existing_dbags.keys & file_dbags.keys
  shared_dbags.each do |dbag|
    deleted_items = existing_dbags[dbag].keys - file_dbags[dbag].keys
    deleted_items.each do |item|
      execute "knife data bag delete #{dbag} #{item}" do
        command "knife data bag delete #{dbag} #{item} -y -c #{configrb}"
      end
    end
  end
end

# new keys not in existing, those are creates
new_dbags = file_dbags.keys - existing_dbags.keys
new_dbags.each do |dbag|
  execute "knife data bag create #{dbag}" do
    command "knife data bag create #{dbag} -c #{configrb}"
  end
end
# items new or changed from existing, those are from file
shared_dbags = file_dbags.keys & existing_dbags.keys
shared_dbags += new_dbags # don't forget the new ones
shared_dbags.each do |dbag|
  file_dbags[dbag].keys.each do |item|
    # compare existing data bag items with those in the file
    next if existing_dbags.key?(dbag) &&
            existing_dbags[dbag].key?(item) &&
            file_dbags[dbag][item].to_json.eql?(existing_dbags[dbag][item].to_json)
    execute "knife data bag from file #{dbag} #{dbag}/#{file_dbags_files[dbag][item]}" do
      command "knife data bag from file #{dbag} #{dbag}/#{file_dbags_files[dbag][item]} -c #{configrb}"
      cwd dbdir
    end
  end
end
