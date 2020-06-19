# follows https://docs.chef.io/upgrade_server/#standalone
resource_name :managed_chef_server_upgrade
provides :managed_chef_server_upgrade

property :package_source, String, name_property: true

action :upgrade do
  upgrade_marker = "#{Chef::Config[:file_cache_path]}/managed_chef_server.upgraded"
  upgrade_package = new_resource.package_source
  upgrade_file = ::File.basename(upgrade_package)

  # Check for upgrade file, exit if already upgraded.
  if ::File.exist?(upgrade_marker)
    # compare the content against the upgrade package
    content = ::File.read(upgrade_marker)
    return if content.match?(upgrade_file)
  end

  # Run the following command to make sure all services are in a sane state.
  execute 'chef-server-ctl reconfigure'

  # Stop the server.
  execute 'chef-server-ctl stop' do
    retries 2 # sometimes it's slow to stop
    retry_delay 10
  end

  # Install the upgrade package, don't allow downgrades.
  package 'chef-server-core' do
    allow_downgrade false
    source upgrade_package
    action :upgrade
  end

  # Upgrade the server, assumes the license has been accepted.
  execute 'chef-server-ctl upgrade'

  # Restart the server.
  execute 'chef-server-ctl start'

  # After the upgrade process is complete and everything is tested and verified
  # to be working properly, clean up the server by removing all of the old data.
  execute 'chef-server-ctl cleanup'

  # Mark that the system has already been upgraded. Re-running this process
  # shouldn't be an issue, but this will save time.
  file upgrade_marker do
    content upgrade_file
  end
end
