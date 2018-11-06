name 'legacy'

include_policy 'base', path: './base.lock.json'

run_list 'managed-chef-server::legacy_loader'

override['mcs']['cookbooks']['dir'] = '/backups/cookbooks'
override['mcs']['environments']['dir'] = '/backups/environments'
override['mcs']['roles']['dir'] = '/backups/roles'
