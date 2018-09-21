# # encoding: utf-8

# Inspec test for recipe managed-chef-server::cron

# backup dir
describe directory('/tmp/kitchen/cache/mcs-cron') do
  it { should exist }
end

describe file('/tmp/kitchen/cache/archive.check') do
  it { should exist }
end

# add crontab entry for cron[knife ec backup]
describe crontab do
  its('commands') { should include 'date >> /var/log/chef/client.log 2>&1; cd /tmp/kitchen/cache/mcs-cron; chef-client -z -F min >> /var/log/chef/client.log 2>&1' }
end

describe crontab.commands('date >> /var/log/chef/client.log 2>&1; cd /tmp/kitchen/cache/mcs-cron; chef-client -z -F min >> /var/log/chef/client.log 2>&1') do
  its('minutes') { should cmp '*/5' }
  its('hours') { should cmp '*' }
  its('days') { should cmp '*' }
end
