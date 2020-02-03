name 'everything'

include_policy 'base', path: './base.lock.json'

run_list 'managed_chef_server::legacy_loader', 'managed_chef_server::policyfile_loader', 'managed_chef_server::maintenance', 'managed_chef_server::backup'

# every 5 minutes for testing
override['mcs']['backup']['cron']['minute'] = '*/5'
override['mcs']['backup']['cron']['hour'] = '*'
override['mcs']['data_bags']['dir'] = '/backups/data_bags'
override['mcs']['policyfile']['dir'] = '/backups/policyfiles'
override['mcs']['cookbooks']['dir'] = '/backups/cookbooks'
override['mcs']['environments']['dir'] = '/backups/environments'
override['mcs']['roles']['dir'] = '/backups/roles'
