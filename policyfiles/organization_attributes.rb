name 'organization_attributes'

include_policy 'base', path: './base.lock.json'

# run_list 'managed_chef_server::data_bag_loader', 'managed_chef_server::organization_attributes'
run_list 'managed_chef_server::organization_attributes'

override['mcs']['data_bags']['dir'] = '/backups/data_bags'
override['mcs']['data_bags']['prune'] = true

override['mcs']['skip_test'] = true
