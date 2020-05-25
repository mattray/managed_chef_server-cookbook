# InSpec test for recipe managed_chef_server::upgrade

describe file '/tmp/kitchen/cache/managed_chef_server.upgraded' do
  it { should exist }
  its('content') { should match /^chef-server-core-13.2.0-1.el7.x86_64.rpm$/ }
end

describe command('rpm -aq | grep chef-server-core') do
  its('stdout') { should match /^chef-server-core-13.2.0-1.el7.x86_64$/ }
end
