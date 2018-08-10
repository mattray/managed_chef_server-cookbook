# managed-chef-server

Deploys and configures the Chef server in a stateless model.

# Recipes

## default ##

Install or restores the Chef Server in a new deployment, wrapping the [https://github.com/chef-cookbooks/chef-server](Chef-Server) cookbook. It looks for the existence of a backup tarball to restore from, configured with the `node['mcs']['restorefile']` attribute. It then creates a managed Chef organization and admin user.

## backups ##

Runs `chef-server-ctl backup` periodically. Probably should use `knife-ec-backup`. Scheduling TBD.

## maintenance ##

Maintaining the Chef server may involve periodically cleaning up stale nodes and unused policyfiles. This is likely to use `knife-tidy` and various `chef` commands. Scheduling TBD.

## policyfile_loader ##

Takes the `node['mcs']['policyfile-directory']` and to load policyfile archives into the local Chef server.
