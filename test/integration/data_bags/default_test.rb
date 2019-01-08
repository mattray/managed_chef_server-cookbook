# # encoding: utf-8

# Inspec test for recipe managed-chef-server::data_bag_loader

# check output of knife commands

describe command('knife data bag list -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^users$/ }
  its ('stdout') { should match /^tests$/ }
end

describe command('knife data bag show users -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should_not match /^user 1$/ } # this one should be pruned
  its ('stdout') { should match /^user2$/ }
  its ('stdout') { should match /^user3$/ }
  its ('stdout') { should match /^user4$/ }
end

# this one is updated by the data_bag_loader
describe command('knife data bag show users user2 -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^name: User 2$/ }
end

describe command('knife data bag show users user3 -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^name: User Three$/ }
end

describe command('knife data bag show tests -c /etc/opscode/managed/config.rb') do
  its ('stdout') { should match /^test1$/ }
  its ('stdout') { should match /^test2$/ }
  its ('stdout') { should match /^test3$/ }
  its ('stdout') { should match /^aye$/ }
end
