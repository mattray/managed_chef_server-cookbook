name 'base'

default_source :supermarket

cookbook 'managed_chef_server', path: '..'

run_list 'managed_chef_server::default', 'managed_chef_server::managed_organization'

override['mcs']['managed_user']['email'] = 'test@foo.com'

override['chef-server']['accept_license'] = true

override['mcs']['org']['name'] = 'test_org'

# override['chef-workstation']['package_source'] = '/backups/chef-workstation-0.15.18-1.el7.x86_64.rpm'
# override['chef-server']['package_source'] = '/backups/chef-server-core-12.19.31-1.el7.x86_64.rpm'
# override['chef-server']['package_source'] = '/backups/chef-server-core-13.1.13-1.el7.x86_64.rpm'
# override['chef-server']['version'] = '12.19.31'
