name 'base'

default_source :supermarket

cookbook 'managed-chef-server', path: '..'

run_list 'managed-chef-server::default', 'managed-chef-server::managed_organization'

override['mcs']['managed_user']['email'] = 'test@foo.com'

override['chef-server']['accept_license'] = true

# override['chefdk']['package_source'] = '/backups/chefdk-3.11.3-1.el7.x86_64.rpm'
# override['chefdk']['package_source'] = '/backups/chefdk-4.2.0-1.el7.x86_64.rpm'
# override['chef-server']['package_source'] = '/backups/chef-server-core-12.19.31-1.el7.x86_64.rpm'
# override['chef-server']['version'] = '12.19.31'
