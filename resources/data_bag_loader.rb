resource_name :data_bag_loader

property :directory, String, name_property: true, required: true
property :organization, String, required: true
property :prune, [true, false], default: false

action :load do
  data_bag_dir = new_resource.directory
  organization = new_resource.organization
  prune = new_resource.prune

  configrb = "/etc/opscode/managed/#{organization}/config.rb"

  # find the data bags by the directory names
  dir_data_bags = Dir.entries(data_bag_dir) - ['.', '..']

  # get list of data bags to manage
  dir_data_bags.each do |data_bag|
    # create if missing
    data_bag "#{organization}:#{data_bag}" do
      organization organization
      data_bag data_bag
      action :create
    end

    data_bag_files = Dir.entries(data_bag_dir + '/' + data_bag) - ['.', '..']

    data_bag_files.sort.each do |item_json| # get items for each
      data_bag "#{organization}:#{data_bag}:#{data_bag_dir}/#{data_bag}/#{item_json}" do
        organization organization
        data_bag data_bag
        item "#{data_bag_dir}/#{data_bag}/#{item_json}"
        action :item_create
      end

    end

    # if prune
    #   data_bag "#{organization}:#{data_bag}:#{data_bag_dir}/#{data_bag}/#{item_json}" do
    #     organization organization
    #     data_bag data_bag
    #     item "#{data_bag_dir}/#{data_bag}/#{item_json}"
    #     action :item_delete
    #   end
    # end

  end

  # if prune is true, get the existing data bags from the server
  if prune
    server_data_bags = shell_out("knife data bag list -c #{configrb}").stdout.split
    # if on server, but not in the directory, remove them
    (server_data_bags - dir_data_bags).each do |prune_data_bag|

      data_bag "#{organization}:#{prune_data_bag}" do
        organization organization
        data_bag prune_data_bag
        action :prune
      end

    end
  end
end
