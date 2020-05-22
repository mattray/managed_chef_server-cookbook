name 'backup'

include_policy 'default', path: './default.lock.json'

run_list 'managed_chef_server::backup'

# every 5 minutes for testing
override['mcs']['backup']['cron']['minute'] = '*/5'
override['mcs']['backup']['cron']['hour'] = '*'

override['mcs']['skip_test'] = true
