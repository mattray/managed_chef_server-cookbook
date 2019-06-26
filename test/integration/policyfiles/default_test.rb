# # encoding: utf-8

# Inspec test for recipe managed-chef-server::policyfiles

# check output of chef show-policy

# verify the ChefDK
describe command('chef') do
  it { should exist }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy -c /etc/opscode/managed/chef_managed_org/config.rb') do
  its ('stdout') { should match /\* base:\s*bea04861be$/ }
  its ('stdout') { should match /\* beaglebone:\s*d99228eafe$/ }
  its ('stdout') { should match /\* macbookpro:\s*3e28786370$/ }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy base -c /etc/opscode/managed/chef_managed_org/config.rb') do
  its ('stdout') { should match /\* base:\s*bea04861be$/ }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy beaglebone -c /etc/opscode/managed/chef_managed_org/config.rb') do
  its ('stdout') { should match /\* beaglebone:\s*d99228eafe$/ }
end

describe command('CHEF_LICENSE="accept-no-persist" chef show-policy macbookpro -c /etc/opscode/managed/chef_managed_org/config.rb') do
  its ('stdout') { should match /\* macbookpro:\s*3e28786370$/ }
  its ('stdout') { should match /\* base:\s*\*NOT APPLIED\*$/ }
  its ('stdout') { should match /\* beaglebone:\s*\*NOT APPLIED\*$/ }
end
