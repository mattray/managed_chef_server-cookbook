# encoding: utf-8

# Inspec test for recipe managed_chef_server::default

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

describe directory('/etc/opscode/managed/test_org') do
  it { should exist }
end

# config.rb
[ '/etc/opscode/managed/test_org/config.rb', '/etc/opscode/managed/test_org/config.json' ].each do |conf|
  describe file conf do
    it { should exist }
    its('mode') { should cmp '0400' }
    its('content') { should match %r{chef_server_url.*https://localhost/organizations/test_org} }
    its('content') { should match /validation_client_name.*test_org/ }
    its('content') { should match %r{validation_key.*/etc/opscode/managed/test_org/test_org-validator.pem} }
    its('content') { should match %r{client_key.*/etc/opscode/managed/test_org/test_org-user.key} }
    its('content') { should match /node_name.*chef_managed_user_test_org/ }
  end
end

describe file '/etc/opscode/managed/test_org/test_org-validator.pem' do
  it { should exist }
end

describe file '/etc/opscode/managed/test_org/test_org-user.key' do
  it { should exist }
end

describe file '/etc/opscode/chef-server.rb' do
  it { should exist }
  its('content') { should match /^opscode_solr4\['heap_size'\] = / }
  its('content') { should match /^postgresql\['checkpoint_completion_target'\] = 0.9$/ }
  its('content') { should match /^postgresql\['checkpoint_segments'\] = 64$/ }
  its('content') { should match /^postgresql\['log_min_duration_statement'\] = 1000$/ }
end
