#
# Cookbook:: managed-chef-server
# Recipe:: default
#

# chef-server install
include_recipe 'chef-server::default'

# Required for restores and backups
package 'rsync'

# no chef-ingredients for restore yet
execute 'chef-server-ctl restore' do
  command "chef-server-ctl restore #{node['mcs']['restorefile']} -c"
  action :nothing
  only_if { ::File.exist?(node['mcs']['restorefile']) }
  subscribes :run, "file[#{Chef::Config[:file_cache_path]}/chef-server-core.firstrun]"
end

# create files for managing the Chef server
directory node['mcs']['managed_user']['dir'] do
  mode '0700'
end

# create organization and validator.pem
org_name = node['mcs']['org']['name']
org_full_name = node['mcs']['org']['full_name']
org_key = node['mcs']['managed_user']['dir'] + '/managed_org.key'
# chef-server-ctl org-create ORG_NAME ORG_FULL_NAME -f FILE_NAME
execute 'chef-server-ctl org-create' do
  command "chef-server-ctl org-create #{org_name} #{org_full_name} -f #{org_key}"
  not_if { ::File.exist?(org_key) }
end

# create a managed user
user_name = node['mcs']['managed_user']['user_name']
user_fn = node['mcs']['managed_user']['first_name']
user_ln = node['mcs']['managed_user']['last_name']
user_email = node['mcs']['managed_user']['email']
user_pass = node['mcs']['managed_user']['password']
user_key = node['mcs']['managed_user']['dir'] + '/managed_user.key'
user_pass = Random.new_seed unless user_pass
# chef-server-ctl user-create USER_NAME FIRST_NAME LAST_NAME EMAIL PASSWORD -f FILE_NAME
execute 'chef-server-ctl user-create' do
  command "chef-server-ctl user-create #{user_name} #{user_fn} #{user_ln} #{user_email} #{user_pass} -f #{user_key}"
  sensitive true
  not_if { ::File.exist?(user_key) }
end

# see if we can get away with not using the server-admins group for now
execute 'chef-server-ctl org-user-add' do
  command "chef-server-ctl org-user-add #{org_name} #{user_name} --admin"
  action :nothing
  subscribes :run, 'execute[chef-server-ctl user-create]', :immediately
end

# execute "chef-server-ctl grant-server-admin-permissions" do
#   command "chef-server-ctl org-user-add #{org_name} #{user_name} --admin"
# end

# write a knife.rb
template "#{node['mcs']['managed_user']['dir']}/knife.rb" do
  source 'knife.erb'
  mode '0700'
  variables(o_key: org_key,
            o_name: org_name,
            u_key: user_key,
            u_name: user_name)
end
