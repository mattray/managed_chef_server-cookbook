rm -rf *json
chef install base.rb
chef install default.rb

chef install backup.rb
chef install cron.rb
chef install data_bags.rb
chef install legacy.rb
chef install policyfile.rb
chef install push-jobs-server.rb
chef install restore.rb

chef install everything.rb
