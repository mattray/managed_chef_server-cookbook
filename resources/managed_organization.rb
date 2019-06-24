resource_name :managed_organization

property :organization, String, name_property: true
property :full_name, String, default: 'Chef Managed Organization'
property :email, String, default: 'test@example.com'
property :password, String

action :create do
  # create organization and validator.pem
  org_name = new_resource.organization
  org_full_name = new_resource.full_name
  org_dir = '/etc/opscode/managed/' + org_name
  org_key = org_dir + '/org.key'

  # create a managed user instead of using the pivotal user
  user_key = org_dir + '/user.key'
  user_name = "chef_managed_user_#{org_name}"
  user_email = new_resource.email
  user_first_name = 'Chef'
  user_last_name = 'Managed'
  user_pass = new_resource_password
  user_pass = Random.new_seed unless user_pass

  # create files for managing the Chef server
  directory org_dir do
    recursive true
    mode '0700'
  end

  # write a config.rb
  template "#{org_dir}/config.rb" do
    source 'config.rb.erb'
    mode '0700'
    variables(
      o_name: org_name,
      o_key: org_key,
      u_name: user_name,
      u_key: user_key,
      )
  end

  # berks config for legacy_loader
  template "#{org_dir}/config.json" do
    source 'config.json.erb'
    mode '0700'
    variables(
      o_name: org_name,
      o_key: org_key,
      u_name: user_name,
      u_key: user_key,
      )
  end

  # chef-server-ctl org-create ORG_NAME ORG_FULL_NAME -f FILE_NAME
  execute 'chef-server-ctl org-create #{org_name}' do
    command "chef-server-ctl org-create #{org_name} #{org_full_name} -f #{org_key}"
    retries 2
    not_if "chef-server-ctl org-list | grep #{org_name}"
  end

  # chef-server-ctl user-create USER_NAME FIRST_NAME LAST_NAME EMAIL PASSWORD -f FILE_NAME
  execute 'chef-server-ctl user-create #{user_name}' do
    command "chef-server-ctl user-create #{user_name} #{user_first_name} #{user_last_name} #{user_email} #{user_pass} -f #{user_key}"
    retries 2
    sensitive true
    not_if "chef-server-ctl user-list | grep #{user_name}"
  end

  # add the managed user to the managed org as an admin
  execute 'chef-server-ctl org-user-add #{org_name} #{user_name}' do
    command "chef-server-ctl org-user-add #{org_name} #{user_name} --admin"
    retries 2
    not_if "chef-server-ctl user-show #{user_name} -l | grep '^organizations:' | grep ' #{org_name}$'"
  end
end
