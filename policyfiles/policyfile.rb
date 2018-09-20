name 'backup'

include_policy 'base', path: './base.lock.json'

run_list 'managed-chef-server::default', 'managed-chef-server::policyfile_loader'
