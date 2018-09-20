name 'cron'

include_policy 'base', path: './base.lock.json'

run_list 'chef-client::config', 'managed-chef-server::default', 'managed-chef-server::cron'

override['chef_client']['config']['chef_zero.enabled'] = true
override['chef_client']['config']['http_retry_delay'] = 10
override['chef_client']['config']['interval'] = 100
override['chef_client']['config']['local_mode'] = true
override['chef_client']['config']['splay'] = 10
override['chef_client']['config']['verbose_logging'] = true
override['chef_client']['cron']['hour'] = '*'
override['chef_client']['cron']['minute'] = '*/5'
