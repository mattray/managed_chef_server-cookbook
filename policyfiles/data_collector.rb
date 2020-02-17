name 'data_collector'

default_source :supermarket

cookbook 'managed_chef_server', path: '..'
cookbook 'mattray', path: '/Users/mattray/ws/cookbooks/mattray'

run_list 'mattray', 'managed_chef_server::default', 'managed_chef_server::managed_organization'

override['chef-server']['accept_license'] = true
override['mcs']['managed_user']['email'] = 'test@foo.com'

override['mcs']['data_collector']['proxy'] = true
override['mcs']['data_collector']['root_url'] = 'https://inez.bottlebru.sh/data-collector/v0/'
override['mcs']['data_collector']['token'] = '35V9X1VO0VRSeUjukPmBsihvwXI='
override['mcs']['profiles']['root_url'] = 'https://inez.bottlebru.sh'

# override['mcs']['skip_test'] = true
