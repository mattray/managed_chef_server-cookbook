#
# Cookbook:: managed-chef-server
# Recipe:: default
#

# chef-server install
include_recipe 'chef-server::default'

# run nginx as a non-root user
include_recipe 'managed-chef-server::_nginx'

# create a managed user instead of using the pivotal user
mudir = node['mcs']['managed_user']['dir']
user_key = mudir + '/managed_user.key'
user_name = node['mcs']['managed_user']['user_name']
user_fn = node['mcs']['managed_user']['first_name']
user_ln = node['mcs']['managed_user']['last_name']
user_email = node['mcs']['managed_user']['email']
user_pass = node['mcs']['managed_user']['password']
user_pass = Random.new_seed unless user_pass
# create organization and validator.pem
org_name = node['mcs']['org']['name']
org_full_name = node['mcs']['org']['full_name']
org_key = mudir + '/managed_org.key'

# create files for managing the Chef server
directory mudir do
  mode '0700'
end

# write a config.rb
template "#{mudir}/config.rb" do
  source 'config.rb.erb'
  mode '0700'
  variables(o_key: org_key,
            o_name: org_name,
            u_key: user_key,
            u_name: user_name)
end

# berks config for legacy_loader
template "#{mudir}/config.json" do
  source 'config.json.erb'
  mode '0700'
  variables(o_key: org_key,
            o_name: org_name,
            u_key: user_key,
            u_name: user_name)
end

# file and directory for restoring from backup
rfile = node['mcs']['restore']['file']
rdir = "#{Chef::Config[:file_cache_path]}/restoredir"

# create restore directory if backup present
directory rdir do
  only_if { !rfile.nil? && ::File.exist?(rfile) }
end

# untar backup if present
execute "tar -C #{rdir} -xzf #{rfile}" do
  action :nothing
  subscribes :run, "directory[#{rdir}]", :immediately
end

# restore from backup if present
execute 'knife ec restore' do
  command "/opt/opscode/embedded/bin/knife ec restore --with-key-sql --with-user-sql -c /etc/opscode/pivotal.rb #{rdir}"
  action :nothing
  subscribes :run, "execute[tar -C #{rdir} -xzf #{rfile}]", :immediately
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

# chef-server-ctl org-create ORG_NAME ORG_FULL_NAME -f FILE_NAME
execute 'chef-server-ctl org-create' do
  command "chef-server-ctl org-create #{org_name} #{org_full_name} -f #{org_key}"
  retries 2
  not_if "chef-server-ctl org-list | grep #{org_name}"
end

# chef-server-ctl user-create USER_NAME FIRST_NAME LAST_NAME EMAIL PASSWORD -f FILE_NAME
execute 'chef-server-ctl user-create' do
  command "chef-server-ctl user-create #{user_name} #{user_fn} #{user_ln} #{user_email} #{user_pass} -f #{user_key}"
  retries 2
  sensitive true
  not_if "chef-server-ctl user-list | grep #{user_name}"
end

# add the managed user to the managed org as an admin
execute 'chef-server-ctl org-user-add' do
  command "chef-server-ctl org-user-add #{org_name} #{user_name} --admin"
  retries 2
  action :nothing
  subscribes :run, 'execute[chef-server-ctl user-create]', :immediately
end

execute 'verify the chef-server is working as expected' do
  command 'chef-server-ctl test'
  action :nothing
  subscribes :run, 'chef_ingredient[chef-server]'
end
