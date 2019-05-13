name 'managed-chef-server'
maintainer 'Matt Ray'
maintainer_email 'matt@chef.io'
license 'Apache-2.0'
description 'Installs and configures a Chef server'
long_description 'Installs and configures a Chef server'
version '0.12.0'
chef_version '>= 13' if respond_to?(:chef_version)

supports 'redhat'
supports 'centos'

depends 'chef-server', '~> 5.5.2'
depends 'chef-ingredient', '~> 3.1.1'

source_url 'https://github.com/mattray/managed-chef-server'
issues_url 'https://github.com/mattray/managed-chef-server/issues'
