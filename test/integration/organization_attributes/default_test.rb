# encoding: utf-8

# Inspec test for recipe managed_chef_server::managed_organization

# check output of knife commands

describe command('knife data bag list -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should_not match /^organizations$/ }
  its('stdout') { should match /^organization$/ }
end

describe command('knife data bag show organization -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^attributes$/ }
  its('stdout') { should match /^profiles$/ }
  its('stdout') { should match /^nodes$/ }
end
