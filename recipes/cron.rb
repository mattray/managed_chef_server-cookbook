#
# Cookbook:: managed-chef-server
# Recipe:: cron
#

# assumes the chef-client is already installed and may be managed by another chef-server
# if a policyfile archive is provided, untar it

crondir = node['mcs']['cron']['zero_dir']
options = node['mcs']['cron']['options'].to_a
archive = node['mcs']['cron']['policyfile_archive']
command = 'chef-client'
options.each { |x| command += " #{x}" }
command += ' >> /var/log/chef/client.log 2>&1'

# check that we're using an archive
if !archive.nil? && ::File.exist?(archive)
  archive_check = Chef::Config[:file_cache_path] + '/archive.check'
  md5sum = shell_out('md5sum', archive)

  # this file updates when the archive changes
  file archive_check do
    content md5sum.stdout
  end

  # delete crondir if archive is new/changed
  directory "delete #{crondir}" do
    path crondir
    recursive true
    action :nothing
    subscribes :delete, "file[#{archive_check}]", :immediately
  end

  directory crondir

  execute "tar -C #{crondir} -xzf #{archive}" do
    action :nothing
    subscribes :run, "directory[#{crondir}]", :immediately
  end

  # chef-client under cron doesn't appreciate PWD
  command = "date >> /var/log/chef/client.log 2>&1; cd #{crondir}; " + command

end

# ensure logging directory
directory '/var/log/chef'

# schedule backup on a recurring cron job. Override attributes as necessary
cron 'chef-client' do
  command command
  minute node['mcs']['cron']['minute']
  hour node['mcs']['cron']['hour']
  day node['mcs']['cron']['day']
end
