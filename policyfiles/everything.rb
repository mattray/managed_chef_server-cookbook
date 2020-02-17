name 'everything'

include_policy 'base', path: './base.lock.json'

run_list 'managed_chef_server::data_bag_loader', 'managed_chef_server::legacy_loader', 'managed_chef_server::policyfile_loader', 'managed_chef_server::backup'

# every 5 minutes for testing
override['mcs']['backup']['cron']['minute'] = '*/5'
override['mcs']['backup']['cron']['hour'] = '*'

override['mcs']['cookbooks']['dir'] = '/backups/cookbooks'
override['mcs']['data_bags']['dir'] = '/backups/data_bags'
override['mcs']['data_collector']['proxy'] = true
override['mcs']['data_collector']['root_url'] = 'https://automate.example.com/data-collector/v0/'
override['mcs']['data_collector']['token'] = 'abcdefghijklmnopqrstuvwxyz'
override['mcs']['environments']['dir'] = '/backups/environments'
override['mcs']['policyfile']['dir'] = '/backups/policyfiles'
override['mcs']['profiles']['root_url'] = 'https://automate.example.com'
override['mcs']['roles']['dir'] = '/backups/roles'
