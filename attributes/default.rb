#
# Cookbook:: managed-chef-server
# Attributes:: default
#
# Copyright:: 2018, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# set location of backup file to restore from
default['mcs']['restorefile'] = ''

# user and organization for Chef-managed server
default['mcs']['org']['name'] = 'chef_managed_org'
default['mcs']['org']['full_name'] = 'Chef Managed Organization'
default['mcs']['managed_user']['dir'] = '/etc/opscode/managed'
default['mcs']['managed_user']['user_name'] = 'chef_managed_user'
default['mcs']['managed_user']['first_name'] = 'Chef'
default['mcs']['managed_user']['last_name'] = 'Managed'
default['mcs']['managed_user']['email'] = 'you@example.com'
default['mcs']['managed_user']['password'] = nil

default['mcs']['policyfile-directory'] = nil
