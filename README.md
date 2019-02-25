# managed-chef-server

Deploys and configures the Chef server in a stateless model.

# Recipes

## default ##

Install or restore the Chef Server in a new deployment, wrapping the [https://github.com/chef-cookbooks/chef-server](Chef-Server) cookbook. It looks for the existence of a knife-ec-backup tarball to restore from, configured with the `node['mcs']['restore']['file']` attribute. It then creates a managed Chef organization and an org-managing admin user.

## backup ##

Runs `knife-ec-backup` via cron. The default is 2:30am daily, but you may change the cron schedule via the following attributes.

    node['mcs']['backup']['cron']['minute'] = '30'
    node['mcs']['backup']['cron']['hour'] = '2'
    node['mcs']['backup']['cron']['day'] = '*'

## cron ##

Installs the Chef server with the chef-client configured to run via cron. This may be set to use chef-zero, for when the Chef server has no other Chef server to reference. See the example [policyfiles/cron.rb](policyfile/cron.rb) and [.kitchen.yml](.kitchen.yml) for reference.

## maintenance ##

Maintaining the Chef server may involve periodically cleaning up stale nodes and unused policyfiles. This is likely to use `knife-tidy` and various `chef` commands. Scheduling and implementation TBD.

## data_bag_loader ##

The `node['mcs']['data_bags']['dir']` is compared against the existing data bags and creates and/or updates them as necessary. If the `node['mcs']['data_bags']['prune']` attribute is `true` then the data bags and their items are deleted as necessary.

## legacy_loader ##

Takes the `node['mcs']['cookbooks']['dir']`, `node['mcs']['environments']['dir']` and `node['mcs']['roles']['dir']` directories and loads whatever content is found into the local Chef server. If you want to use the same directory for the roles and environments the recipe can distinguish between JSON files. The cookbooks are expected to be tarballs in a directory, they will all be attempted to load via their `Berksfile` or with `knife`. For legacy cookbooks with multiple dependencies it may take multiple runs to load everything.

## policyfile_loader ##

Takes the `node['mcs']['policyfile']['dir']` and parses any `.lock.json` files to determine which policyfile archives to load into the local Chef server. Policies will be assigned to the group designated by the `node['mcs']['policyfile']['group']` attribute for the Chef server (`_default` is the default). If the policy itself sets the `node['mcs']['policyfile']['group']` attribute, the policy will be assigned to that group.

# Attributes

Additional attributes are documented in the [attributes/default.rb](attributes/default.rb).

# Testing

There is a [.kitchen.yml](.kitchen.yml) that may be used for testing with Vagrant. The [.kitchen.vagrant.yml](.kitchen.vagrant.yml) may be symlinked as **.kitchen.local.yml** and used with local caches to speed up testing. If you want to use Docker, [.kitchen.dokken.yml](.kitchen.dokken.yml) may be used but it does not persist changes between runs and is thus not significantly faster (it's slower than Vagrant with caching). The following Suites map to example [policyfiles](policyfiles) that may be repurposed as necessary:

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

## License and Authors

- Author: Matt Ray [matt@chef.io](mailto:matt@chef.io)
- Copyright 2018, Chef Software, Inc

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
