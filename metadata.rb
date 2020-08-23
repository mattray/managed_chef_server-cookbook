name 'managed_chef_server'
maintainer 'Matt Ray'
maintainer_email 'matt@chef.io'
license 'Apache-2.0'
description 'Installs and configures a Chef server'
version '0.18.6'
chef_version '>= 15'

supports 'redhat'
supports 'centos'
supports 'debian'

depends 'chef-server', '~> 5.6'
depends 'chef-ingredient', '~> 3.2'

source_url 'https://github.com/mattray/managed_chef_server-cookbook'
issues_url 'https://github.com/mattray/managed_chef_server-cookbook/issues'
