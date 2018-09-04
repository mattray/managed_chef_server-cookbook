# managed-chef-server

Deploys and configures the Chef server in a stateless model.

# Recipes

## default ##

Install or restore the Chef Server in a new deployment, wrapping the [https://github.com/chef-cookbooks/chef-server](Chef-Server) cookbook. It looks for the existence of a knife-ec-backup tarball to restore from, configured with the `node['mcs']['restore']['file']` attribute. It then creates a managed Chef organization and an org-managing admin user.

## backups ##

Runs `knife-ec-backup` periodically. Scheduling TBD but will likely consist of using `edit_resource!` to override a `cron` resource. Implementation and documentation TBW.

## maintenance ##

Maintaining the Chef server may involve periodically cleaning up stale nodes and unused policyfiles. This is likely to use `knife-tidy` and various `chef` commands. Scheduling and implementation TBD.

## policyfile_loader ##

Takes the `node['mcs']['policyfile']['dir']` and parses any `.lock.json` files to determine which policyfile archives to load into the local Chef server.

# Attributes

Additional attributes are documented in the [attributes/default.rb](attributes/default.rb).

# Testing

There is a [.kitchen.yml](.kitchen.yml) that may be used for testing with Vagrant. The [.kitchen.vagrant.yml](.kitchen.vagrant.yml) may be symlinked as **.kitchen.local.yml** and used with local caches and examples caching the chef-server.rpm and chefdk.rpms to speed up testing. If you want to use Docker, [.kitchen.dokken.yml](.kitchen.dokken.yml) may be used but it does not persist changes between runs and is thus not significantly faster (it's slower than Vagrant with caching). Each contains the following Suites:

## default

Tests simple installation and creation of the managed Chef user and organization.

## backup

Adds automated backups via `cron` to the default recipe.

## restore

Restores the Chef server from a backup with policyfiles. `kitchen verify restore` ensures the policyfiles were restored properly.

## policyfile

Adds loading policyfiles from the included [test](test) directory.

## everything

Installs the Chef server, restores from a backup, attempts to load policyfiles (which are included in the restored backup) and adds backups via cron.


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
