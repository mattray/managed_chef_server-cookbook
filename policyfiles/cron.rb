name 'cron'

include_policy 'base', path: './base.lock.json'

run_list 'managed-chef-server::cron'

# every 5 minutes for testing
override['mcs']['cron']['minute'] = '*/5'
override['mcs']['cron']['options'] = ['-z', '-F min']

override['mcs']['skip_test'] = true
