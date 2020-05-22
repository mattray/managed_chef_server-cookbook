name 'policyfile'

include_policy 'default', path: './default.lock.json'

run_list 'managed_chef_server::policyfile_loader'

override['mcs']['policyfile']['dir'] = '/backups/policyfiles'

override['mcs']['skip_test'] = true
