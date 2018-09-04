# # encoding: utf-8

# Inspec test for recipe managed-chef-server::policyfiles

# check output of chef show-policy

# verify the ChefDK
describe command('chef') do
  it { should exist }
end

describe command('chef show-policy -c /etc/opscode/managed/knife.rb') do
  its ('stdout') { should match /\* base:        bea04861be$/ }
  its ('stdout') { should match /\* beaglebone:  d99228eafe$/ }
  its ('stdout') { should match /\* macbookpro:  3e28786370$/ }
end
