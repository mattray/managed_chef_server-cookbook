resource_name :data_bag

property :data_bag, String, required: true
property :item_json, String, required: true
property :organization, String, required: true

action :create do
  data_bag = new_resource.data_bag
  item_json = new_resource.item_json
  organization = new_resource.organization
  configrb = "/etc/opscode/managed/#{organization}/config.rb"
  data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags"

  # calculate MD5 of the data_bag item file
  md5sum = shell_out('md5sum', item_json)

  # if data bag is not there, create it
  execute "knife data bag create #{data_bag} #{organization}" do
    command "knife data bag create #{data_bag} -c #{configrb}"
    only_if { shell_out("grep #{data_bag} #{data_bag_md5s}").error? }
  end

  # if the data bag item has not been uploaded, upload it
  execute "knife data bag from file #{data_bag} #{item_json} to #{organization}" do
    command "knife data bag from file #{data_bag} #{item_json} -c #{configrb}"
    only_if { shell_out("grep #{md5sum.stdout.split[0]} #{data_bag_md5s}").error? }
  end

  execute "record #{data_bag} #{item_json} MD5" do
    command "echo #{md5sum.stdout.strip} >> #{data_bag_md5s}"
    action :nothing
    subscribes :run, "execute[knife data bag from file #{data_bag} #{item_json} to #{organization}]", :immediately
  end
end

# action :item_delete do
#   data_bag = new_resource.data_bag
#   item = new_resource.item
#   configrb = "/etc/opscode/managed/#{new_resource.organization}/config.rb"
#   data_bag_md5s = "#{Chef::Config[:file_cache_path]}/mcs-databags"

#   # check MD5 in the md5 file
#   md5sum = shell_out('md5sum', item)

#   # if the data bag item has not been uploaded, upload it
#   execute "knife data bag delete #{data_bag} #{item}" do
#     only_if 'grep #{md5sum.stdout} #{data_bag_md5s}'
#   end

#   execute "record #{data_bag} #{item_json} MD5" do
#     command "echo #{md5sum.stdout} >> #{data_bag_md5s}"
#     action :nothing
#     subcribes :run, "knife data bag from file #{data_bag} #{item_json}", :immediately
#   end
# end
