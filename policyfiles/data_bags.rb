name 'data_bags'

include_policy 'base', path: './base.lock.json'

run_list 'managed-chef-server::data_bag_loader'

# override['mcs']['restore']['file'] = '/backups/chef-server-backup-201811110055.tgz' # pre-baked with 2 data bag items existing
override['mcs']['data_bags']['dir'] = '/backups/data_bags'
