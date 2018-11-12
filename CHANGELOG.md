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


# BACKLOG

- maintenance tasks
