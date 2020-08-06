# the data bags that are loaded on the Chef server are tracked in the various
# mcs-databags-* files with their items and md5 sums because this is much faster
# than making a full scrape of the Chef server every run. If these files are
# removed, they'll re-upload to the Chef server which shouldn't be an issue

resource_name :managed_data_bag
provides :managed_data_bag

property :data_bag, String, required: true
property :organization, String, required: true
property :item, String

# creates a new data bag unless there's already an entry for it in the
# file tracking items that have been pushed to the Chef Server
action :create do
  data_bag = new_resource.data_bag
  organization = new_resource.organization

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"
  data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags-#{organization}"

  shell_out("touch #{data_bag_md5s}")
  bag_exists = !shell_out("grep ^#{data_bag}: #{data_bag_md5s}").error?

  unless bag_exists
    execute "knife data bag create #{data_bag} #{organization}" do
      command "knife data bag create #{data_bag} -c #{configrb}"
    end
  end
end

# delete the data bag and remove entries from the file tracking items pushed to
# the Chef Server. Logic for identifying bags to prune is from data_bag_loader
action :prune do
  data_bag = new_resource.data_bag
  organization = new_resource.organization

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"
  data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags-#{organization}"

  bash "knife_data_bag_delete #{data_bag}" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
knife data bag delete #{data_bag} -y -c #{configrb}
sed -i '/^#{data_bag}/d' #{data_bag_md5s}
    EOH
  end
end

# create a new data bag item from the JSON file providing it and track the entry
# through the bag, item ID and MD5
action :item_create do
  data_bag = new_resource.data_bag
  item_json = new_resource.item
  organization = new_resource.organization

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"
  data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags-#{organization}"

  item = JSON.parse(::File.read(item_json))
  item_id = item['id']

  md5sum = shell_out('md5sum', item_json).stdout.split[0]
  item_exists = !shell_out("grep #{data_bag}:#{item_id}:#{md5sum} #{data_bag_md5s}").error?

  unless item_exists
    # remove any previous items, create data bag item, add item to data_bag_md5s
    bash "knife data bag from file #{data_bag} #{item_json} to #{organization}" do
      cwd Chef::Config[:file_cache_path]
      code <<-EOH
sed -i '/^#{data_bag}:#{item_id}/d' #{data_bag_md5s}
knife data bag from file #{data_bag} #{item_json} -c #{configrb}
echo #{data_bag}:#{item_id}:#{md5sum} >> #{data_bag_md5s}
      EOH
    end
  end
end

# delete the data bag item if it is not in the file tracking items pushed to
# the Chef Server. data_bag_loader checks items for verifying to prune them
action :item_prune do
  organization = new_resource.organization
  data_bag = new_resource.data_bag
  item = new_resource.item

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"

  execute "knife data bag delete #{data_bag} #{item} from #{organization}" do
    command "knife data bag delete #{data_bag} #{item} -y -c #{configrb}"
  end
end
