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

# config.rb
describe file '/etc/opscode/managed/config.rb' do
  it { should exist }
end

describe file '/etc/opscode/chef-server.rb' do
  it { should exist }
  its('content') { should match /^opscode_solr4\['heap_size'\] = / }
  its('content') { should match /^postgresql\['checkpoint_completion_target'\] = 0.9$/ }
  its('content') { should match /^postgresql\['checkpoint_segments'\] = 64$/ }
  its('content') { should match /^postgresql\['log_min_duration_statement'\] = 1000$/ }
end
