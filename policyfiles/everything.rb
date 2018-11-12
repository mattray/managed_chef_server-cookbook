name 'everything'

include_policy 'base', path: './base.lock.json'

run_list 'managed-chef-server::legacy_loader', 'managed-chef-server::policyfile_loader', 'managed-chef-server::maintenance', 'managed-chef-server::backup'

# every 5 minutes for testing
override['mcs']['backup']['cron']['minute'] = '*/5'
override['mcs']['backup']['cron']['hour'] = '*'
override['mcs']['policyfile']['dir'] = '/backups/policyfiles'
override['mcs']['cookbooks']['dir'] = '/backups/cookbooks'
override['mcs']['environments']['dir'] = '/backups/environments'
override['mcs']['roles']['dir'] = '/backups/roles'
