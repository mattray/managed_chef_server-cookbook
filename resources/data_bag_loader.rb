resource_name :data_bag_loader
provides :data_bag_loader

property :directory, String, name_property: true
property :organization, String, required: true
property :prune, [true, false], default: false

action :load do
  data_bag_dir = new_resource.directory
  organization = new_resource.organization
  prune = new_resource.prune

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"
  data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags-#{organization}"

  return if data_bag_dir.nil? || !Dir.exist?(data_bag_dir)

  # find the data bags to manage by the directory names
  dir_data_bags = Dir.entries(data_bag_dir) - ['.', '..']

  # get existing server data bags and remove any that aren't on the filesystem
  if prune
    server_data_bags = shell_out("knife data bag list -c #{configrb}").stdout.split
    # if on server, but not in the directory, remove them
    (server_data_bags - dir_data_bags).each do |prune_data_bag|
      managed_data_bag "#{organization}:#{prune_data_bag}" do
        organization organization
        data_bag prune_data_bag
        action :prune
      end
    end
  end

  # manage contents of each data bag
  dir_data_bags.each do |data_bag|
    # create data bags if missing
    managed_data_bag "#{organization}:#{data_bag}" do
      organization organization
      data_bag data_bag
      action :create
    end

    data_bag_files = Dir.entries(data_bag_dir + '/' + data_bag) - ['.', '..']

    # prune first, then re-add later if not in the MD5 file
    if prune
      md5_items = shell_out("grep ^#{data_bag} #{data_bag_md5s}").stdout.split
      if md5_items.count > data_bag_files.count # reset md5s if > than files #
        shell_out("sed -i '/^#{data_bag}/d' #{data_bag_md5s}")
      end
      # query the server for the IDs and prune any extras
      server_items = shell_out("knife data bag show #{data_bag} -c #{configrb}").stdout.split
      server_items.sort.each do |item| # sort for clearer logging
        next unless shell_out("grep ^#{data_bag}:#{item} #{data_bag_md5s}").error?
        managed_data_bag "#{organization}:#{data_bag}:#{item}" do
          organization organization
          data_bag data_bag
          item item
          action :item_prune
        end
      end
    end

    # create items for each json entry
    data_bag_files.sort.each do |item_json| # sort for clearer logging
      managed_data_bag "#{organization}:#{data_bag}:#{data_bag_dir}/#{data_bag}/#{item_json}" do
        organization organization
        data_bag data_bag
        item "#{data_bag_dir}/#{data_bag}/#{item_json}"
        action :item_create
      end
    end
  end
end
