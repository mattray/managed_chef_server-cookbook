# managed-chef-server CHANGELOG

This file is used to list changes made in each version of the managed-chef-server cookbook.

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

- [https://github.com/mattray/managed-chef-server-cookbook/issues/11](more retries built in with chef-server-ctl commands)

# 0.7.2

- [https://github.com/mattray/managed-chef-server-cookbook/issues/7](legacy_loader is now idempotent and validates .rb environments and roles)


# BACKLOG

- maintenance tasks
sudo /opt/chef/embedded/bin/inspec exec inspec-chef-server --attrs=config.yml
sudo /opt/chef/embedded/bin/inspec exec https://github.com/chef/inspec-chef-server.git --attrs=config.yml
inspec exec https://github.com/mattray/inspec-chef-server/tree/rhel --attrs=config.yml
inspec exec https://github.com/mattray/inspec-chef-server/tree/rhel --target=ssh://192.168.33.22:2222 --user=vagrant --key-files=~/.vagrant.d/insecure_private_key --attrs=test/config.yml --sudo
