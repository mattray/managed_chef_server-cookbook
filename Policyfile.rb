name 'default'

default_source :supermarket

cookbook 'managed_chef_server', path: '.'
cookbook 'test_cookbook', path: 'test/integration/test_cookbook/' # just for data_collector /etc/hosts testing

run_list 'managed_chef_server', 'managed_chef_server::managed_organization'
named_run_list :backup, 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::backup'
named_run_list :cron, 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::cron'
named_run_list :data_collector, 'test_cookbook', 'managed_chef_server', 'managed_chef_server::managed_organization'
named_run_list :data_bags, 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::data_bag_loader'
named_run_list :legacy, 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::legacy_loader'
named_run_list :policyfile, 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::policyfile_loader'
named_run_list :restore, 'managed_chef_server::restore', 'managed_chef_server::managed_organization'
named_run_list :upgrade, 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::upgrade'
named_run_list :everything, 'test_cookbook', 'managed_chef_server', 'managed_chef_server::managed_organization', 'managed_chef_server::data_bag_loader', 'managed_chef_server::legacy_loader', 'managed_chef_server::policyfile_loader', 'managed_chef_server::backup', 'managed_chef_server::upgrade'

# default settings
default['chef-server']['accept_license'] = true
default['mcs']['managed_user']['email'] = 'test@foo.com'
default['mcs']['org']['name'] = 'test_org'

# backup testing every 5 minutes
default['mcs']['backup']['cron']['minute'] = '*/5'
default['mcs']['backup']['cron']['hour'] = '*'

# cron testing
default['mcs']['cron']['minute'] = '*/5'
default['mcs']['cron']['options'] = ['--local-mode', '-F min']
default['mcs']['cron']['policyfile_archive'] = '/backups/policyfiles/base-53e07f37074575abfe75bbb74032f6cd63fc566ff2b8e655f9a2ddf91a3615a8.tgz'

# data bag testing
default['mcs']['data_bags']['dir'] = '/backups/data_bags'
default['mcs']['data_bags']['prune'] = true

# legacy testing
default['mcs']['cookbooks']['dir'] = '/backups/cookbooks'
default['mcs']['environments']['dir'] = '/backups/environments'
default['mcs']['roles']['dir'] = '/backups/roles'

# policyfile testing
default['mcs']['policyfile']['dir'] = '/backups/policyfiles'

# restore testing
default['mcs']['restore']['file'] = '/backups/chef-server-backup-202002192050.tgz'

# package sources, these may be overridden in the kitchen.yml as necessary
# default['chef-server']['package_source'] = '/backups/chef-server-core-13.2.0-1.el7.x86_64.rpm'
# default['chef-workstation']['package_source'] = '/backups/chef-workstation-0.18.3-1.el7.x86_64.rpm'
