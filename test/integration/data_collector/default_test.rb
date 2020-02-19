# encoding: utf-8

# Inspec test for recipe managed_chef_server::_data_collector

describe file '/etc/opscode/chef-server.rb' do
  it { should exist }
  its('content') { should match %r{^data_collector\['root_url'\] = 'https://inez.bottlebru.sh/data-collector/v0/'} }
  its('content') { should match /^data_collector\['proxy'\] = true/ }
  its('content') { should match %r{^profiles\['root_url'\] = 'https://inez.bottlebru.sh'} }
end
