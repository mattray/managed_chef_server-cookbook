#
# Cookbook:: managed_chef_server
# Attributes:: default
#

# upgrade package
default['mcs']['upgrade']['package_source'] = nil

# _data_collection recipe
default['mcs']['data_collector']['token'] = nil
default['mcs']['data_collector']['root_url'] = nil
default['mcs']['data_collector']['proxy'] = false
default['mcs']['profiles']['root_url'] = nil

# restore recipe
# set location of backup file to restore from
default['mcs']['restore']['file'] = nil

# managed organization for Chef-managed server
default['mcs']['managed']['dir'] = '/etc/opscode/managed'
default['mcs']['org']['name'] = 'chef_managed_org'
default['mcs']['org']['full_name'] = 'Chef Managed Organization'
# if you want an email address for the managed organization users
default['mcs']['managed_user']['email'] = nil
# if you want a non-random password for the user
default['mcs']['managed_user']['password'] = nil

# backup recipe
# schedule via cron
default['mcs']['backup']['cron']['minute'] = '30'
default['mcs']['backup']['cron']['hour'] = '2'
default['mcs']['backup']['cron']['day'] = '*'
default['mcs']['backup']['cron']['month'] = '*'
default['mcs']['backup']['cron']['weekday'] = '*'
default['mcs']['backup']['dir'] = Chef::Config[:file_cache_path] + '/mcs-backups'
# this will have the timestamp added
default['mcs']['backup']['prefix'] = 'chef-server-backup-'

# cron recipe
default['mcs']['cron']['minute'] = '*/30'
default['mcs']['cron']['hour'] = '*'
default['mcs']['cron']['day'] = '*'
default['mcs']['cron']['month'] = '*'
default['mcs']['cron']['weekday'] = '*'
default['mcs']['cron']['options'] = []
default['mcs']['cron']['policyfile_archive'] = nil
default['mcs']['cron']['zero_dir'] = Chef::Config[:file_cache_path] + '/mcs-cron'

# data_bag_loader recipe
default['mcs']['data_bags']['dir'] = nil
default['mcs']['data_bags']['prune'] = false

# Chef Workstation attributes cargo-culted for compatibility
default['chef-workstation']['channel'] = :stable
default['chef-workstation']['version'] = 'latest'
default['chef-workstation']['package_source'] = nil

# legacy_loader recipe
default['mcs']['cookbooks']['dir'] = nil
default['mcs']['environments']['dir'] = nil
default['mcs']['roles']['dir'] = nil

# policyfile_loader recipe
default['mcs']['policyfile']['dir'] = nil
default['mcs']['policyfile']['group'] = '_default'
default['mcs']['policyfile']['lockfiletype'] = '.lock.json'
default['mcs']['policyfile']['purge'] = false

# added to allow skipping chef-server-ctl test for already deployed systems
default['mcs']['skip_test'] = false

# _tuning recipe
# if you want to configure the settings in the _tuning recipe you may set these
# please refer to the recipe source for explanations and documentation links
default['mcs']['opscode_solr4']['heap_size'] = nil
