name 'chef-server'

run_list 'managed-chef-server::default'
named_run_list 'backup', 'managed-chef-server::default', 'managed-chef-server::backup'
named_run_list 'restore', 'managed-chef-server::default', 'chefdk::default' # chefdk is for testing
named_run_list 'policyfiles', 'managed-chef-server::default', 'managed-chef-server::policyfile_loader'
named_run_list 'everything', 'managed-chef-server::default', 'managed-chef-server::policyfile_loader', 'managed-chef-server::maintenance', 'managed-chef-server::backup'

default_source :supermarket

cookbook 'managed-chef-server', path: '..'
