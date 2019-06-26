name 'base'

default_source :supermarket

cookbook 'managed-chef-server', path: '..'

run_list 'managed-chef-server::default'

override['mcs']['managed_user']['email'] = 'test@foo.com'

override['chefdk']['package_source'] = '/backups/chefdk-4.0.60-1.el7.x86_64.rpm'
override['chef-server']['package_source'] = '/backups/chef-server-core-12.19.31-1.el7.x86_64.rpm'
