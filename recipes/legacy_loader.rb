#
# Cookbook:: managed-chef-server
# Recipe:: legacy_loader
#

# load directories for cookbooks, environments, and roles into the Chef server
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'

# cookbooks
cbdir = node['mcs']['cookbooks']['dir']
# cscookbooks =  "knife cookbook list -c #{configrb}"
Dir.foreach(cbdir) do |cookbook|
  # if the cookbook directories have versions in the name, knife cookbook upload * -c /etc/opscode/managed/config.rb -o . doesn't work
  # if you specify each individually, they need their dependencies resolved :(
  # knife cookbook upload build-essential mingw seven_zip windows -c /etc/opscode/managed/config.rb -o . works
  # we'll have to untar/zip archives and read their metadata.rb
  # execute "knife cookbook upload #{cookbook}" do
  #   command "knife cookbook upload #{cookbook} -c #{configrb} -o #{cbdir}"
  #   # do we need guards?
  # end
end

# environments
envdir = node['mcs']['environments']['dir']
Dir.foreach(envdir) do |env|
  next unless env.end_with?('.rb') || env.end_with?('.json')
  if env.end_with?('.json')   # if it's .json, check the type
    json = JSON.parse(File.read(envdir + '/' + env))
    type = json['chef_type']
    next unless type.eql?('environment')
  end
  # we could make this idempotent by comparing the value on the server
  execute "knife environment from file #{env}" do
    command "knife environment from file #{env} -c #{configrb}"
    cwd "#{envdir}"
  end
end

# roles
roledir = node['mcs']['roles']['dir']
Dir.foreach(roledir) do |role|
  next unless role.end_with?('.rb') || role.end_with?('.json')
  if role.end_with?('.json') # if it's .json, check the type
    json = JSON.parse(File.read(roledir + '/' + role))
    type = json['chef_type']
    next unless type.eql?('role')
  end
  # we could make this idempotent by comparing the value on the server
  execute "knife role from file #{role}" do
    command "knife role from file #{role} -c #{configrb}"
    cwd "#{roledir}"
  end
end


# data bags to be added eventually
