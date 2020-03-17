set -e
rm -rf ~/.chefdk/cache
rm -rf *json

chef install base.rb
chef install default.rb

chef install data_collector.rb
chef install backup.rb
chef install cron.rb
chef install policyfile.rb
chef install data_bags.rb
chef install organization_attributes.rb
chef install legacy.rb
chef install restore.rb

chef install everything.rb
