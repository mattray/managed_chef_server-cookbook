# # encoding: utf-8

# Inspec test for recipe managed-chef-server::legacy

# check output of knife commands

describe command('knife cookbook list -c /etc/opscode/managed/config.rb') do
end

describe command('knife environment list -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^_default$/ }
  its ('stdout') { should match /^essex$/ }
  its ('stdout') { should match /^lab$/ }
  its ('stdout') { should match /^vagrant$/ }
  its ('stdout') { should_not match /^lab-admin$/ }
end

describe command('knife role list -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^base$/ }
  its ('stdout') { should match /^lab-admin$/ }
  its ('stdout') { should match /^lab-base$/ }
  its ('stdout') { should_not match /^lab-environment$/ }
end
