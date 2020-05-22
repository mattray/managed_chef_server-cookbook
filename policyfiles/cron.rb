name 'cron'

include_policy 'default', path: './default.lock.json'

run_list 'managed_chef_server::cron'

# every 5 minutes for testing
override['mcs']['cron']['minute'] = '*/5'
override['mcs']['cron']['options'] = ['--local-mode', '-F min']

override['mcs']['cron']['policyfile_archive'] = '/backups/policyfiles/base-53e07f37074575abfe75bbb74032f6cd63fc566ff2b8e655f9a2ddf91a3615a8.tgz'

override['mcs']['skip_test'] = true
