# encoding: utf-8

# Inspec test for recipe managed_chef_server::legacy

# check output of knife commands

describe command('knife environment list -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^_default$/ }
  its('stdout') { should match /^essex$/ }
  its('stdout') { should match /^lab$/ }
  its('stdout') { should match /^vagrant$/ }
  its('stdout') { should_not match /^lab-admin$/ }
end

describe command('knife role list -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^base$/ }
  its('stdout') { should match /^lab-admin$/ }
  its('stdout') { should match /^lab-base$/ }
  its('stdout') { should_not match /^lab-environment$/ }
end

# these are going to drift because of Berkshelf
describe command('knife cookbook list -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^apt\s+7.3.0$/ }
  its('stdout') { should match /^chef-client\s+11.0.3$/ }
  its('stdout') { should match /^cron\s+6.3.1$/ }
  its('stdout') { should match /^iptables\s+4.3.4$/ }
  its('stdout') { should match /^logrotate\s+2.2.3$/ }
  its('stdout') { should match /^mattray\s+0.8.0$/ }
  its('stdout') { should match /^ntp\s+3.6.0/ }
  its('stdout') { should match /^sudo\s+5.5.0/ }
end

describe command('knife cookbook show ntp -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^ntp.*3.6.0/ }
end

describe command('knife cookbook show sudo -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^sudo.*5.4.0$/ }
end
