# # encoding: utf-8

# Inspec test for recipe managed-chef-server::default

# This is an example test, replace it with your own test.
describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe directory('/etc/opscode/managed') do
  it { should exist }
end

describe directory('/etc/opscode/managed/chef_managed_org') do
  it { should exist }
end

# config.rb
[ '/etc/opscode/managed/chef_managed_org/config.rb', '/etc/opscode/managed/chef_managed_org/config.json' ].each do |conf|
  describe file conf do
    it { should exist }
    its('mode') { should cmp '0400' }
    its('content') { should match /chef_server_url.*https:\/\/localhost\/organizations\/chef_managed_org/ }
    its('content') { should match (/validation_client_name.*chef_managed_org/) }
    its('content') { should match (/validation_key.*\/etc\/opscode\/managed\/chef_managed_org\/org.key/) }
    its('content') { should match (/client_key.*\/etc\/opscode\/managed\/chef_managed_org\/user.key/) }
    its('content') { should match (/node_name.*chef_managed_user_chef_managed_org/) }
  end
end

describe file '/etc/opscode/managed/chef_managed_org/org.key' do
  it { should exist }
end

describe file '/etc/opscode/managed/chef_managed_org/user.key' do
  it { should exist }
end

describe file '/etc/opscode/chef-server.rb' do
  it { should exist }
  its('content') { should match /^opscode_solr4\['heap_size'\] = / }
  its('content') { should match /^postgresql\['checkpoint_completion_target'\] = 0.9$/ }
  its('content') { should match /^postgresql\['checkpoint_segments'\] = 64$/ }
  its('content') { should match /^postgresql\['log_min_duration_statement'\] = 1000$/ }
end
