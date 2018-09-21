name 'everything'

include_policy 'base', path: './base.lock.json'

run_list 'managed-chef-server::policyfile_loader', 'managed-chef-server::maintenance', 'managed-chef-server::backup'
