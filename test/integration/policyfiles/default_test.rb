# encoding: utf-8

# Inspec test for recipe managed_chef_server::policyfiles

# check output of chef show-policy

# verify the ChefDK
describe command('chef') do
  it { should exist }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^base$/ }
  its('stdout') { should match /^\*\s_default:\s*bea04861be$/ }
  its('stdout') { should match /^\*\shome:\s*\*NOT\sAPPLIED\*$/ }
  its('stdout') { should match /^beaglebone$/ }
  its('stdout') { should match /^\*\s_default:\s*d99228eafe$/ }
  its('stdout') { should match /^macbookpro$/ }
  its('stdout') { should match /^\*\s_default:\s*\*NOT\sAPPLIED\*$/ }
  its('stdout') { should match /^\*\shome:\s*3e28786370$/ }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy base -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^base$/ }
  its('stdout') { should match /^\*\s_default:\s*bea04861be$/ }
  its('stdout') { should match /^\*\shome:\s*\*NOT\sAPPLIED\*$/ }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy beaglebone -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^beaglebone$/ }
  its('stdout') { should match /^\*\s_default:\s*d99228eafe$/ }
  its('stdout') { should match /^\*\shome:\s*\*NOT\sAPPLIED\*$/ }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy macbookpro -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^macbookpro$/ }
  its('stdout') { should match /^\*\s_default:\s*\*NOT\sAPPLIED\*$/ }
  its('stdout') { should match /^\*\shome:\s*3e28786370$/ }
end
