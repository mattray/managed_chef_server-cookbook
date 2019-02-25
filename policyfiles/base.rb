name 'base'

default_source :supermarket

cookbook 'managed-chef-server', path: '..'

run_list 'managed-chef-server::default'

# override['chefdk']['package_source'] = '/backups/chefdk-3.1.0-1.el7.x86_64.rpm'
# override['chef-server']['package_source'] = '/backups/chef-server-core-12.17.33-1.el7.x86_64.rpm'

override['mcs']['skip_test'] = false
