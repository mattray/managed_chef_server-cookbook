name 'default'

default_source :supermarket

cookbook 'managed_chef_server', path: '..'

run_list 'managed_chef_server::default', 'managed_chef_server::managed_organization'


override['chef-server']['accept_license'] = true
override['mcs']['managed_user']['email'] = 'test@foo.com'
override['mcs']['org']['name'] = 'test_org'
