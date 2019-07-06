# managed-chef-server

Deploys and configures the Chef server in a relatively stateless model. The included [policyfiles](policyfiles) provide examples of deployment options and the required attributes.

# Recipes

## default ##

Install or restore the Chef Server in a new deployment, wrapping the [Chef-Server](https://github.com/chef-cookbooks/chef-server) cookbook. It looks for the existence of a [knife-ec-backup](https://github.com/chef/knife-ec-backup) tarball to restore from, configured with the `node['mcs']['restore']['file']` attribute. It then creates a managed Chef organization and an org-managing admin user through the appropriate [attributes](attributes/default.rb#24).

## backup ##

Runs `knife ec backup` via cron and puts the backups in the `node['mcs']['backup']['dir']`. The default is 2:30am daily, but you may change the cron schedule via the following attributes.

    node['mcs']['backup']['cron']['minute'] = '30'
    node['mcs']['backup']['cron']['hour'] = '2'
    node['mcs']['backup']['cron']['day'] = '*'
    node['mcs']['backup']['cron']['month'] = '*'
    node['mcs']['backup']['cron']['weekday'] = '*'

## cron ##

Schedules the Chef client to run on the Chef server via cron against a provided policyfile archive. This may be set to use `--local-mode`, for when the Chef client has no other Chef server to contact. See the example [policyfiles/cron.rb](policyfiles/cron.rb) and [kitchen.yml](kitchen.yml) for reference.

## data_bag_loader ##

The `node['mcs']['data_bags']['dir']` is compared against the existing data bags on the server and creates and/or updates them as necessary. If the `node['mcs']['data_bags']['prune']` attribute is `true` then the data bags and their items are deleted if they exist on the server but do not have the requisite JSON files.

## legacy_loader ##

Takes the `node['mcs']['cookbooks']['dir']`, `node['mcs']['environments']['dir']` and `node['mcs']['roles']['dir']` directories and loads whatever content is found into the local Chef server. If you want to use the same directory for the roles and environments the recipe can distinguish between JSON files. The cookbooks are expected to be tarballs in a directory, they will all be attempted to load via their `Berksfile` or with `knife`. For legacy cookbooks with multiple dependencies it may take multiple runs to load everything.

## policyfile_loader ##

Takes the `node['mcs']['policyfile']['dir']` and parses any `.lock.json` files to determine which policyfile archives to load into the local Chef server. Policies will be assigned to the group designated by the `node['mcs']['policyfile']['group']` attribute for the Chef server (`_default` is the default). If the policy itself sets the `node['mcs']['policyfile']['group']` attribute, the policy will be assigned to that group.

# Testing

There is a [kitchen.yml](kitchen.yml) that may be used for testing with Vagrant. The [kitchen.vagrant.yml](kitchen.vagrant.yml) may be symlinked as **kitchen.local.yml** and used with local caches to speed up testing. If you want to use Docker, [kitchen.dokken.yml](kitchen.dokken.yml) may be used but it does not persist changes between runs and is thus not significantly faster (it's slower than Vagrant with caching). The following Suites map to example [policyfiles](policyfiles) that may be repurposed as necessary:

## default

Tests simple installation and creation of the managed Chef user and organization.

## restore

Restores the Chef server from a backup with policyfiles. `kitchen verify restore` ensures the policyfiles were restored properly.

## cron

Checks the chef-client is in the crontab

## backup

Checks the backup script is in the crontab and backup directories are available.

## data_bags

Adds loading data bags from the included [test](test) directory. It restores from a previous data bag backup to ensure pruning and updating work.

## policyfile

Adds loading policyfiles from the included [test](test) directory.

## legacy

Adds loading cookbooks, environments and roles from the included [test](test) directory.

## everything

Installs the Chef server, restores from a backup, attempts to load policyfiles (which are included in the restored backup) and adds backup via cron.

# Attributes
The [default.rb](attributes/default.rb) attributes file documents available settings and tunings.

# Custom Resources

Custom resources are used to reduce the complexity of the included recipes.

## managed_organization

The `:create` action will instantiate a Chef server organization with an internal administrator user. The name properties is the `organization`. The organization's `full_name`, `email`, and `password` are all optional properties.

## chef_server_backup

This resource schedules backups of the Chef server via cron-style properties (`minute`, `hour`, `day`, `month`, `weekday`). The backups are written to the `directory` and their filenames start with the `prefix`.

## chef_server_cron

This resource requires an `archive` property specifying the policyfile archive to deploy and use for running via `cron`.

## chef_server_restore

This resource requires a `tarball` property specifying the `knife ec backup` tarball to restore from.

## data_bag_loader

This resource works off of the `directory` property specifying the source for the data bags to keep in sync with the server.

## data_bag

This has `:create`, `:prune`, `:item_create`, and `:item_prune` for managing the data bags available on the server. This custom resource is called from the `data_bag_loader` resource.

## policyfile_loader

This resource looks for policyfile locks and archives in the `directory` specifying the source, only uploading them if they have been updated.

# License and Authors

- Author: Matt Ray [matt@chef.io](mailto:matt@chef.io)
- Copyright 2018-2019, Chef Software, Inc

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
