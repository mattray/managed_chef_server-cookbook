resource_name :environments_loader
provides :environments_loader

property :directory, String, name_property: true
property :organization, String, required: true

action :load do
  environments_dir = new_resource.directory
  organization = new_resource.organization

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"

  return if environments_dir.nil? || !Dir.exist?(environments_dir)

  # find existing policies on the server
  server_environments = {}

  shell_out("knife environment list -c #{configrb}").stdout.each_line do |environment|
    environment.strip!
    next if environment.nil? || environment.empty?
    content = JSON.load(shell_out!("knife environment show #{environment} -c #{configrb} --format json").stdout)
    server_environments[environment] = content
  end

  Dir.foreach(environments_dir) do |environment|
    next unless environment.end_with?('.rb', '.json')
    if environment.end_with?('.json')
      json = JSON.parse(::File.read(environments_dir + '/' + environment))
    else # it's .rb
      e = Chef::Environment.new
      e.from_file(environments_dir + '/' + environment)
      json = JSON.load(e.to_json)
    end
    type = json['chef_type']
    next unless type.eql?('environment')
    name = json['name']
    execute "knife environment from file #{environment}" do
      command "knife environment from file #{environment} -c #{configrb}"
      cwd environments_dir
      not_if { server_environments.key?(name) && json.eql?(server_environments[name]) }
    end
  end
end
