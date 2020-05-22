name 'legacy'

include_policy 'default', path: './default.lock.json'

run_list 'managed_chef_server::legacy_loader'

override['mcs']['cookbooks']['dir'] = '/backups/cookbooks'
override['mcs']['environments']['dir'] = '/backups/environments'
override['mcs']['roles']['dir'] = '/backups/roles'

override['mcs']['skip_test'] = true
