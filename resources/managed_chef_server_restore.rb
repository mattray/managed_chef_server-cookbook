resource_name :managed_chef_server_restore
provides :managed_chef_server_restore

property :tarball, String, name_property: true

action :run do
  # file and directory for restoring from backup
  restore_file = new_resource.tarball
  restore_dir = "#{Chef::Config[:file_cache_path]}/restoredir"

  # create restore directory if backup present
  directory restore_dir do
    only_if { defined?(restore_file) && ::File.exist?(restore_file) }
  end

  # untar backup if present
  execute "tar -C #{restore_dir} -xzf #{restore_file}" do
    action :nothing
    subscribes :run, "directory[#{restore_dir}]", :immediately
  end

  # restore from backup if present
  execute 'knife ec restore' do
    environment('PATH' => '/opt/opscode/embedded/bin:$PATH')
    command "/opt/opscode/embedded/bin/knife ec restore --with-key-sql --with-user-sql -c /etc/opscode/pivotal.rb #{restore_dir}"
    action :nothing
    subscribes :run, "execute[tar -C #{restore_dir} -xzf #{restore_file}]", :immediately
  end
end
