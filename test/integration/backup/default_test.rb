# encoding: utf-8

# Inspec test for recipe managed_chef_server::backup

# backup dir
describe directory('/tmp/kitchen/cache/mcs-backups') do
  it { should exist }
end

describe file('/tmp/kitchen/cache/mcs-backups/backup.sh') do
  it { should exist }
  it { should be_executable }
end

# add crontab entry for cron[knife ec backup]
describe crontab do
  its('commands') { should include '/tmp/kitchen/cache/mcs-backups/backup.sh' }
end

describe crontab.commands('/tmp/kitchen/cache/mcs-backups/backup.sh') do
  its('minutes') { should cmp '*/5' }
  its('hours') { should cmp '*' }
end
