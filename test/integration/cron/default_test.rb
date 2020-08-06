# encoding: utf-8

# Inspec test for recipe managed_chef_server::cron

# defaults brought over, testing with different managed org dir
describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe directory('/root/managed') do
  it { should exist }
end

describe directory('/root/managed/test_org') do
  it { should exist }
end

# config.rb
[ '/root/managed/test_org/config.rb', '/root/managed/test_org/config.json' ].each do |conf|
  describe file conf do
    it { should exist }
    its('mode') { should cmp '0400' }
    its('content') { should match %r{chef_server_url.*https://localhost/organizations/test_org} }
    its('content') { should match /validation_client_name.*test_org/ }
    its('content') { should match %r{validation_key.*/root/managed/test_org/test_org-validator.pem} }
    its('content') { should match %r{client_key.*/root/managed/test_org/test_org-user.key} }
    its('content') { should match /node_name.*chef_managed_user_test_org/ }
  end
end

describe file '/root/managed/test_org/test_org-validator.pem' do
  it { should exist }
end

describe file '/root/managed/test_org/test_org-user.key' do
  it { should exist }
end

describe file '/etc/opscode/chef-server.rb' do
  it { should exist }
  its('content') { should match /^opscode_solr4\['heap_size'\] = / }
  its('content') { should match /^postgresql\['checkpoint_completion_target'\] = 0.9$/ }
  its('content') { should match /^postgresql\['checkpoint_segments'\] = 64$/ }
  its('content') { should match /^postgresql\['log_min_duration_statement'\] = 1000$/ }
end


# cron dir
describe directory('/tmp/kitchen/cache/mcs-cron') do
  it { should exist }
end

describe file('/tmp/kitchen/cache/archive.check') do
  it { should exist }
end

# add crontab entry for cron[knife ec backup]
describe crontab do
  its('commands') { should include 'date >> /var/log/chef/client.log 2>&1; cd /tmp/kitchen/cache/mcs-cron; chef-client --local-mode -F min >> /var/log/chef/client.log 2>&1' }
end

describe crontab.commands('date >> /var/log/chef/client.log 2>&1; cd /tmp/kitchen/cache/mcs-cron; chef-client --local-mode -F min >> /var/log/chef/client.log 2>&1') do
  its('minutes') { should cmp '*/5' }
  its('hours') { should cmp '*' }
  its('days') { should cmp '*' }
end
