# # encoding: utf-8

# Inspec test for recipe managed-chef-server::data_bag_loader

# check output of knife commands

describe command('knife data bag list -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^users$/ }
  its ('stdout') { should match /^tests$/ }
end

describe command('knife data bag show users -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should_not match /^user 1$/ } # this one should be pruned
  its ('stdout') { should match /^user 2$/ }
  its ('stdout') { should match /^user 3$/ }
  its ('stdout') { should match /^user 4$/ }
end

# this one is updated by the data_bag_loader
describe command('knife data bag show users user2 -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^User Two$/ }
end

describe command('knife data bag show users user3 -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^User Three$/ }
end

describe command('knife data bag show tests -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^Test One$/ }
  its ('stdout') { should match /^Test Two$/ }
  its ('stdout') { should match /^Test Three$/ }
end
