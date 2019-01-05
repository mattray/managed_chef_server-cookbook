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
  puts dbag
  existing_dbags[dbag] = {}
  items = `knife data bag show #{dbag} -c #{configrb}`.split
  items.each do |item|
    puts "EXISTING-#{dbag}::#{item}"
    content = `knife data bag show #{dbag} #{item} -c #{configrb} --format json`
    existing_dbags[dbag][item] = content
  end
end

puts "EXISTING-"+existing_dbags

# get list of data bags to manage
file_dbags = {}
file_dbags_files = {} # file associated with the data bag items
unless dbdir.nil?
  Dir.foreach(dbdir) do |dbag|
    next if ['.', '..'].member?(dbag)
    puts dbag
    file_dbags[dbag] = {}
    file_dbags_files[dbag] = {}
    bagdir = dbdir + '/' + dbag
    Dir.foreach(bagdir) do |itemfile| # get items for each
      next if ['.', '..'].member?(itemfile)
      puts "FILE-#{dbag}::#{itemfile}"
      # read in JSON for comparison?
      item = JSON.parse(File.read(bagdir + '/' + itemfile))
      file_dbags[dbag][item['id']] = item
      file_dbags_files[dbag][item['id']] = itemfile
      # convert hash to data bag item?
    end
  end
end

puts "FILE-"+file_dbags

# if we are pruning we are deleting unmanaged data bags and items
if prune
  # existing keys not in new, those are deletes
  deleted_dbags = existing_dbags.keys - file_dbags.keys
  deleted_dbags.each do |dbag|
    execute "knife data bag delete #{dbag}" do
      command "knife data bag delete #{dbag} -c #{configrb}"
    end
  end
  # existing items not in new, those are deletes
  shared_dbags = existing_dbags.keys & file_dbags.keys
  shared_dbags.each do |dbag|
    deleted_items = existing_dbags[dbag].keys - file_dbags[dbag].keys
    deleted_items.each do |item|
      execute "knife data bag delete #{dbag} #{item}" do
        command "knife data bag delete #{dbag} #{item} -c #{configrb}"
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
shared_dbags.each do |dbag|
  file_dbags[dbag].keys.each do |item|
    # can you knife data bag create item with JSON?
    execute "knife data bag from file #{dbag} #{file_dbags_files[item]}" do
      command "knife data bag from file #{dbag} #{file_dbags_files[item]} -c #{configrb}"
      cwd dbdir
    end
  end
end
