resource_name :roles_loader

property :directory, String, name_property: true, required: true
property :organization, String, required: true

action :load do
  roles_dir = new_resource.directory
  organization = new_resource.organization

  configrb = "/etc/opscode/managed/#{organization}/config.rb"

  return if roles_dir.nil? || roles_dir.empty?

  # find existing policies on the server
  server_roles = {}

  shell_out("knife role list -c #{configrb}").stdout.each_line do |role|
    role.strip!
    next if role.nil? || role.empty?
    content = JSON.load(shell_out!("knife role show #{role} -c #{configrb} --format json").stdout)
    server_roles[role] = content
  end

  Dir.foreach(roles_dir) do |role|
    next unless role.end_with?('.rb', '.json')
    if role.end_with?('.json')
      json = JSON.parse(::File.read(roles_dir + '/' + role))
    else # it's .rb
      roll = Chef::Role.new
      roll.from_file(roles_dir + '/' + role)
      json = JSON.load(roll.to_json)
    end
    type = json['chef_type']
    next unless type.eql?('role')
    name = json['name']
    execute "knife role from file #{role}" do
      command "knife role from file #{role} -c #{configrb}"
      cwd roles_dir
      not_if { server_roles.key?(name) && json.eql?(server_roles[name]) }
    end
  end
end
