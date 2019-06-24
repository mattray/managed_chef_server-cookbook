#
# Cookbook:: managed-chef-server
# Recipe:: default
#

# performance tuning based off of recommendations in https://docs.chef.io/server_tuning.html#large-node-sizes
include_recipe 'managed-chef-server::_tuning'

# chef-server install
include_recipe 'chef-server::default'

# run nginx as a non-root user
include_recipe 'managed-chef-server::_nginx'

# restore from a backup if present
chef_server "restore Chef server from backup" do
  tarball node['mcs']['restore']['file']
  action :restore
  only_if { node['mcs']['restore']['file'] }
end

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
  not_if "chef-server-ctl user-show #{user_name} -l | grep '^organizations:' | grep ' #{org_name}$'"
end

execute 'verify the chef-server is working as expected' do
  command 'chef-server-ctl test'
  action :nothing
  subscribes :run, 'chef_ingredient[chef-server]'
  not_if { node['mcs']['skip_test'] }
end
