#
# Cookbook:: managed-chef-server
# Recipe:: backup
#

# put some sort of backup regime in place
# Implement monitoring and backups: No Chef infrastructure is complete without automated backup and monitoring procedures in place before launch. For backups, take the following 3 tiers as an example:
#     Hourly backups using snapshots
#     Daily backups of the filesystem
#     Weekly full export using knife-ec-backup

# Puts the initial backup in the /var/opt/chef-backup directory as a tar.gz file; move this backup to a new location for safe keeping
execute 'chef-server-ctl backup -y' do
  only_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/chef-server-core.firstrun") }
end

# do an object backup occasionally?
# https://github.com/chef/knife-ec-backup
