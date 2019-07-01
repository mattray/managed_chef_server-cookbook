resource_name :data_bag_loader

property :directory, String, name_property: true, required: true
property :organization, String, required: true
# property :prune, Boolean, default: false

action :load do
  data_bag_dir = new_resource.directory
  organization = new_resource.organization
  # prune = new_resource.prune

  # get list of data bags to manage
  Dir.foreach(data_bag_dir) do |data_bag|
    next if ['.', '..'].member?(data_bag)

    data_bag "#{organization}:#{data_bag}" do
      organization organization
      data_bag data_bag
      action :create
    end

    Dir.foreach(data_bag_dir + '/' + data_bag) do |item_json| # get items for each
      next if ['.', '..'].member?(item_json)

      data_bag "#{organization}:#{data_bag}:#{data_bag_dir}/#{data_bag}/#{item_json}" do
        organization organization
        data_bag data_bag
        item_json "#{data_bag_dir}/#{data_bag}/#{item_json}"
        action :item_create
      end

    end
  end
end
