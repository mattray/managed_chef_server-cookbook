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

# 0.8.0

- [https://github.com/mattray/managed-chef-server-cookbook/pull/17](added skipping the Chef Server pedant tests)


# 0.9.0

- Added support for policyfiles to set their policy group by setting the `['mcs']['policyfile']['group']` attribute

# 0.10.0

- Skip existing policies to speed up loading
- remove chefdk cookbook dependency in favor of directly using chef_ingredient

# 0.11.0

- Added private performance tuning recipe [_tuning.rb](recipes/_tuning.rb)

# BACKLOG

## maintenance recipe ##

Maintaining the Chef server may involve periodically cleaning up stale nodes and unused policies. This is likely to use `knife-tidy` and various `chef` commands. Scheduling and implementation TBD.

- refactor into libraries to reduce Ruby in recipes
- refactor default recipe to split install and restores
- inspec for configuration checks
  inspec exec https://github.com/mattray/inspec-chef-server/tree/rhel --attrs=config.yml
