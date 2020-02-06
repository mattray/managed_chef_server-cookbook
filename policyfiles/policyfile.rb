name 'policyfile'

include_policy 'base', path: './base.lock.json'

run_list 'managed_chef_server::policyfile_loader'

override['mcs']['policyfile']['dir'] = '/backups/policyfiles'

override['mcs']['skip_test'] = true
