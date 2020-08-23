# managed_chef_server CHANGELOG

This file is used to list changes made in each version of the managed_chef_server cookbook.

# 0.1.0
- Initial release.
- Installation and recovery of Chef server.
- Creation of managed organization and user for managing the server.
- Skeleton of tests.

# 0.2.0
- cookstyle cleanups
- example policyfiles for testing
- policyfile_loader recipe

# 0.3.0
- restore from backup works
- Chef 13.8.5 testing

# 0.3.1
- switch to config.rb from knife.rb

# 0.4.0
- refactor policyfiles for more straightforward testing
- backup scheduled via cron and attributes
- cron recipe for managing the chef-server with the chef-client under cron, with or without a policyfile archive

# 0.5.0
- legacy loader for cookbooks, environments, roles
- nginx as non-root (@chrisg-fastlane)

# 0.6.0
- legacy loader recipe supports Berkshelf
- fix some issues with the restore for the managed user

# 0.6.1
- legacy loader skip an empty cookbook list

# 0.6.2
- policyfile_loader now puts policyfiles in a _default policygroup as defined by an attribute.

# 0.7.0
- data_bag_loader recipe and tests

# 0.7.1
- [https://github.com/mattray/managed_chef_server-cookbook/issues/11](more retries built in with chef-server-ctl commands)

# 0.7.2
- [https://github.com/mattray/managed_chef_server-cookbook/issues/7](legacy_loader is now idempotent and validates .rb environments and roles)

# 0.8.0
- [https://github.com/mattray/managed_chef_server-cookbook/pull/17](added skipping the Chef Server pedant tests)

# 0.9.0
- Added support for policyfiles to set their policy group by setting the `['mcs']['policyfile']['group']` attribute

# 0.10.0
- Skip existing policies to speed up loading
- remove chefdk cookbook dependency in favor of directly using chef_ingredient

# 0.11.0
- Added private performance tuning recipe [_tuning.rb](recipes/_tuning.rb)

# 0.12.0
- lowered precedence of tuning attributes to default from overkill
- add the admin user to the org if it's missing, not just on a first create
- ensure the data bag directory exists when loading data bags
- [https://github.com/mattray/managed_chef_server-cookbook/pull/22](refactor to use rubyblocks instead of raw ruby in recipes, fixes race conditions)

# 0.13.0
- minimum Chef version is now 14
- added Chef 15 support for all CLIs
- new kitchen test suites for testing Chef 14 and 15 versions

# 0.14.0
- new _chefdk.rb private recipe for installing the ChefDK
- refactor new Custom Resources
  - managed_organization :create
  - chef_server_backup :create
  - chef_server_cron :create
  - chef_server_restore :run
  - cookbooks_loader :load
  - data_bag_loader :load
  - data_bag :create, :prune, :item_create, :item_prune (all called by the data_bag_loader)
  - environments_loader :load
  - policyfile_loader :load
  - roles_loader :load
- the following attributes were removed to simplify managing multiple organizations
  -default['mcs']['managed_user']['dir']
  -default['mcs']['managed_user']['user_name']
  -default['mcs']['managed_user']['first_name']
  -default['mcs']['managed_user']['last_name']
- the following attributes were added to expand cron coverage
  -default['mcs']['backup']['cron']['month'] = '*'
  -default['mcs']['backup']['cron']['weekday'] = '*'
  -default['mcs']['cron']['month'] = '*'
  -default['mcs']['cron']['weekday'] = '*'
- all the loaders now support organizations

# 0.15.0
- refactored custom resources to not conflict with existing Chef resources (ie. `data_bag`) and renamed them for clarity.
- [include _chefdk.rb in default.rb](https://github.com/mattray/managed_chef_server-cookbook/issues/29) for compatibility with wrapper cookbooks
- [refactored managed_organization out to a separate recipe](https://github.com/mattray/managed_chef_server-cookbook/issues/28) for supporting multiple organizations
- [refactored organization keys to unique names](https://github.com/mattray/managed_chef_server-cookbook/issues/27)

# 0.15.1
- [updated the condition to validate the existence of data bag item](https://github.com/mattray/managed_chef_server-cookbook/issues/33)
- [updated the condition to validate the existence of data bag](https://github.com/mattray/managed_chef_server-cookbook/issues/33)

# 0.16.0
- [rename cookbook to managed_chef_server](https://github.com/mattray/managed_chef_server-cookbook/issues/30)
- Accept the Chef Infra Server 13 license if `node['chef-server']['accept_license']` is set
- [Clean up old backup directory recursively](https://github.com/mattray/managed_chef_server-cookbook/issues/35)

# 0.17.0
- [switched to Chef Workstation from ChefDK](https://github.com/mattray/managed_chef_server-cookbook/issues/38)
- [remove Chef Workstation from chef-client path](https://github.com/mattray/managed_chef_server-cookbook/issues/36)
- refactor default recipe to split install and restores
- rename managed org keys to `-validator.pem`
- backup and restore the managed organization validator pems
- configure data collection with private `_data_collector` recipe
- switch tests over to 'test_org' to make it easier to see in Automate

# 0.18.0
- dropped Chef 14 support, add Chef 16 support
- [workstation installation is overwriting chef-client symlink with non-existent destination](https://github.com/mattray/managed_chef_server-cookbook/issues/40)
- added sleep while loop to wait for startup completion
- refactored testing policyfiles to be easier to follow
- move license acceptance into a private recipe.
- upgrade recipe

# 0.18.1
- updated custom resources to account for [breaking Custom Resource change in Chef 16.2](https://discourse.chef.io/t/chef-infra-client-16-2-released/17284)

# 0.18.2
- [attempt to fix issue with missing directory](https://github.com/mattray/managed_chef_server-cookbook/issues/42)

# 0.18.3
- sort policyfiles by time to avoid potential race condition

# 0.18.4
- [make location of the directory containing managed users configurable](https://github.com/mattray/managed_chef_server-cookbook/issues/45)

# 0.18.5
- specify cookbook source of files and templates for external custom resource usage

# 0.18.6
- [on restore, copy the validator.pem without subscribing to the user reset](https://github.com/mattray/managed_chef_server-cookbook/issues/47)

# NEXT
- organization attributes

# Backlog
- Chef 16: clean up end.run_action https://docs.chef.io/release_notes/#compile_time-on-all-resources
- Chef 16: improve property require behavior https://docs.chef.io/release_notes/#improved-property-require-behavior

## maintenance recipe
Maintaining the Chef server may involve periodically cleaning up stale nodes and unused policies. This is likely to use `knife-tidy` and various `chef` commands. Scheduling and implementation TBD.
- inspec for configuration checks
  inspec exec https://github.com/mattray/inspec-chef-server/tree/rhel --attrs=config.yml
- investigate `chef-server-ctl cleanup`
- knife tidy
