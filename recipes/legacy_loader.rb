#
# Cookbook:: managed-chef-server
# Recipe:: legacy_loader
#

# need the ChefDK for the 'berks' command
include_recipe 'managed-chef-server::_chefdk'

# load directories for cookbooks, environments, and roles into the Chef server
configrb = "/etc/opscode/managed/#{node['mcs']['org']['name']}/config.rb"
configjson = "/etc/opscode/managed/#{node['mcs']['org']['name']}/config.json"

# cookbooks
cbdir = node['mcs']['cookbooks']['dir']
cbtempdir = Chef::Config[:file_cache_path] + '/legacycookbooks'
directory cbtempdir

# untar into temp directory named after the tarball
Dir.foreach(cbdir) do |tarfile|
  next unless tarfile.end_with?('.tgz', '.tar.gz')
  tfcbdir = cbtempdir + '/' + tarfile.gsub(/.tgz$|.tar.gz$/, '')
  tfmarker = tfcbdir + '-TAR'
  directory tfcbdir
  # untar each cookbook
  execute "tar -xzf #{tarfile}" do
    cwd cbdir
    command "tar -C #{tfcbdir} -xzf #{tarfile}"
    not_if { File.exist?(tfmarker) }
  end
  # marker file indicating not to untar again
  file tfmarker do
    action :nothing
    subscribes :create, "execute[tar -xzf #{tarfile}]", :immediately
  end
  # if there's a Berksfile, go to town
  berksmarker = tfcbdir + '-BERKS'
  knifemarker = tfcbdir + '-KNIFE'
  ruby_block "berks install/upload #{tarfile}" do
    block do
      berksfile = tfcbdir + '/' + shell_out("ls #{tfcbdir}").stdout.chomp + '/Berksfile'
      shell_out!("berks install -b #{berksfile} -c #{configjson}")
      shell_out!("berks upload -b #{berksfile} -c #{configjson}")
    end
    only_if { File.exist?(tfcbdir + '/' + shell_out("ls #{tfcbdir}").stdout.chomp + '/Berksfile') }
    not_if { File.exist?(berksmarker) }
    not_if { File.exist?(knifemarker) }
    notifies :create, "file[#{berksmarker}]", :immediately
  end
  file berksmarker do
    action :nothing
  end
  # we'll try knife cookbook upload otherwise. This could take multiple passes given dependencies
  execute "knife cookbook upload #{tarfile}" do
    command "knife cookbook upload -a -c #{configrb} -o #{tfcbdir}"
    ignore_failure true
    not_if { File.exist?(berksmarker) }
    not_if { File.exist?(knifemarker) }
    notifies :create, "file[#{knifemarker}]", :immediately
  end
  file knifemarker do
    action :nothing
  end
end

# environments
environments_loader node['mcs']['environments']['dir'] do
  organization node['mcs']['org']['name']
end

# roles
roles_loader node['mcs']['roles']['dir'] do
  organization node['mcs']['org']['name']
end
