resource_name :data_bag_loader

property :directory, String, name_property: true, required: true
property :organization, String, required: true
# property :prune, Boolean, default: false

action :load do
  db_dir = new_resource.directory
  organization = new_resource.organization
  #  prune = new_resource.prune

  configrb = "/etc/opscode/managed/#{organization}/config.rb"

  # get list of data bags to manage
  file_dbags = {}
  file_dbags_files = {}

  # get list of data bags to manage
  Dir.foreach(db_dir) do |data_bag|
    next if ['.', '..'].member?(data_bag)
    Dir.foreach(db_dir + '/' + data_bag) do |item_json| # get items for each
      next if ['.', '..'].member?(item_json)

      data_bag "#{organization}:#{data_bag}:#{db_dir}/#{data_bag}/#{item_json}" do
        organization organization
        data_bag data_bag
        item_json "#{db_dir}/#{data_bag}/#{item_json}"
      end

    end
  end
end
