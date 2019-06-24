resource_name :chef_server

property :tarball, String, name_property: true, required: true

action :restore do
  # file and directory for restoring from backup
  restore_file = new_resource.tarball
  restore_dir = "#{Chef::Config[:file_cache_path]}/restoredir"

  # create restore directory if backup present
  directory restore_dir do
    only_if { !restore_file.nil? && ::File.exist?(restore_file) }
  end

  # untar backup if present
  execute "tar -C #{restore_dir} -xzf #{restore_file}" do
    action :nothing
    subscribes :run, "directory[#{restore_dir}]", :immediately
  end

  # restore from backup if present
  execute 'knife ec restore' do
    command "/opt/opscode/embedded/bin/knife ec restore --with-key-sql --with-user-sql -c /etc/opscode/pivotal.rb #{restore_dir}"
    action :nothing
    subscribes :run, "execute[tar -C #{restore_dir} -xzf #{restore_file}]", :immediately
  end

  # on restore, reset the private key
  execute 'delete managed user key on restore' do
    command "chef-server-ctl delete-user-key #{user_name} default"
    retries 2
    action :nothing
    subscribes :run, 'execute[knife ec restore]', :immediately
  end

  execute 'reset managed user key on restore' do
    command "chef-server-ctl add-user-key #{user_name} --key-name default > #{user_key}"
    retries 2
    action :nothing
    subscribes :run, 'execute[delete managed user key on restore]', :immediately
  end
end
