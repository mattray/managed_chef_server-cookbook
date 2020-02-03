name 'data_bags'

include_policy 'base', path: './base.lock.json'

run_list 'managed_chef_server::data_bag_loader'

override['mcs']['data_bags']['dir'] = '/backups/data_bags'
override['mcs']['data_bags']['prune'] = true

override['mcs']['skip_test'] = true
