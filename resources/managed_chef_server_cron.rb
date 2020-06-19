resource_name :managed_chef_server_cron
provides :managed_chef_server_cron

property :archive, String, name_property: true
property :minute, String, default: '*'
property :hour, String, default: '*'
property :day, String, default: '*'
property :month, String, default: '*'
property :weekday, String, default: '*'

action :create do
  archive = new_resource.archive
  crondir = node['mcs']['cron']['zero_dir']

  # chef-client under cron doesn't appreciate PWD
  command = "date >> /var/log/chef/client.log 2>&1; cd #{crondir}; chef-client"
  node['mcs']['cron']['options'].to_a.each { |x| command += " #{x}" }
  command += ' >> /var/log/chef/client.log 2>&1'

  if ::File.exist?(archive)
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
  end

  # ensure logging directory
  directory '/var/log/chef'

  # schedule chef-client on a recurring cron job. Override attributes as necessary
  cron 'chef-client' do
    command command
    minute new_resource.minute
    hour new_resource.hour
    day new_resource.day
    month new_resource.month
    weekday new_resource.weekday
  end
end
