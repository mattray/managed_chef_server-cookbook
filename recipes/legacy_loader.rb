#
# Cookbook:: managed-chef-server
# Recipe:: legacy_loader
#

# need the ChefDK for the 'berks' command
chef_ingredient 'chefdk' do
  action :install
  version node['chefdk']['version']
  channel node['chefdk']['channel']
  package_source node['chefdk']['package_source']
end.run_action(:install)

# load directories for cookbooks, environments, and roles into the Chef server
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'
configjson = node['mcs']['managed_user']['dir'] + '/config.json'

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
existing_environments = {}
list = shell_out("knife environment list -c #{configrb}").stdout.split
list.each do |env|
  content = JSON.load(shell_out!("knife environment show #{env} -c #{configrb} --format json").stdout)
  existing_environments[env] = content
end

envdir = node['mcs']['environments']['dir']
Dir.foreach(envdir) do |env|
  next unless env.end_with?('.rb', '.json')
  if env.end_with?('.json')
    json = JSON.parse(File.read(envdir + '/' + env))
  else # it's .rb
    environment = Chef::Environment.new
    environment.from_file(envdir + '/' + env)
    json = JSON.load(environment.to_json)
  end
  type = json['chef_type']
  next unless type.eql?('environment')
  name = json['name']
  next if existing_environments.key?(name) &&
          json.eql?(existing_environments[name])
  execute "knife environment from file #{env}" do
    command "knife environment from file #{env} -c #{configrb}"
    cwd envdir
  end
end

# roles
existing_roles = {}
list = shell_out("knife role list -c #{configrb}").stdout.split
list.each do |role|
  content = JSON.load(shell_out!("knife role show #{role} -c #{configrb} --format json").stdout)
  existing_roles[role] = content
end

roledir = node['mcs']['roles']['dir']
Dir.foreach(roledir) do |role|
  next unless role.end_with?('.rb', '.json')
  if role.end_with?('.json')
    json = JSON.parse(File.read(roledir + '/' + role))
  else # it's .rb
    roll = Chef::Role.new
    roll.from_file(roledir + '/' + role)
    json = JSON.load(roll.to_json)
  end
  type = json['chef_type']
  next unless type.eql?('role')
  name = json['name']
  next if existing_roles.key?(name) &&
          json.eql?(existing_roles[name])
  execute "knife role from file #{role}" do
    command "knife role from file #{role} -c #{configrb}"
    cwd roledir
  end
end
