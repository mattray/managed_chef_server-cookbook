resource_name :managed_organization_databag

property :organizations, String, default: 'organizations'
property :organization, String, name_property: true

action :create do
  global_orgs = new_resource.organizations
  local_org = new_resource.organization

  configrb = "/etc/opscode/managed/#{local_org}/config.rb"
  data_bag_dir = "#{Chef::Config[:file_cache_path]}/mcs-databags-#{local_org}-organization"
  data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags-#{local_org}"

  # find the organization from the master data bag of all organizations
  begin
    orgs_item = data_bag_item(global_orgs, local_org)
  rescue Net::HTTPServerException
    log "NO #{local_org} DATA BAG ITEM FOUND IN #{global_orgs}"
    return
  end

  # create the organization data bag if it's not already present
  managed_data_bag "#{local_org}:organization" do
    organization local_org
    data_bag 'organization'
    action :create
    not_if "knife data bag show organization -c #{configrb}"
  end

  if Dir.exist?(data_bag_dir) # empty out contents each time
    FileUtils.rm_rf(Dir.glob("#{data_bag_dir}/*"))
  else
    Dir.mkdir(data_bag_dir)
  end

  # for each key in the parent organization data bag item create a JSON file
  orgs_item.keys.each do |key|
    next if key.eql?('id') # this one is extraneous
    item = orgs_item[key]
    item['id'] = key unless item['id']
    ::File.write("#{data_bag_dir}/#{key}.json", item.to_json)
  end

  data_bag_files = Dir.entries(data_bag_dir) - ['.', '..']

  # stash MD5s
  # prune first, then re-add later if not in the MD5 file
  md5_items = shell_out("grep ^organization #{data_bag_md5s}").stdout.split
  if md5_items.count > data_bag_files.count # reset md5s if > than files #
    shell_out("sed -i '/^organization:/d' #{data_bag_md5s}")
  end
  # query the server for the IDs and prune any extras
  server_items = shell_out("knife data bag show organization -c #{configrb}").stdout.split
  server_items.sort.each do |item| # sort for clearer logging
    next unless shell_out("grep ^organization:#{item} #{data_bag_md5s}").error?
    managed_data_bag "#{local_org}:organization:#{item}" do
      organization local_org
      data_bag 'organization'
      item item
      action :item_prune
    end
  end

  # create items for each json entry
  data_bag_files.sort.each do |item_json| # sort for clearer logging
    managed_data_bag "#{local_org}:organization:#{data_bag_dir}/#{item_json}" do
      organization local_org
      data_bag 'organization'
      item "#{data_bag_dir}/#{item_json}"
      action :item_create
    end
  end
end
