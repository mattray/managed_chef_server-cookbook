resource_name :policyfile_loader
provides :policyfile_loader

property :directory, String, name_property: true
property :organization, String, required: true

action :load do
  policyfile_dir = new_resource.directory
  organization = new_resource.organization

  configrb = "#{node['mcs']['managed']['dir']}/#{organization}/config.rb"

  return if policyfile_dir.nil? || !Dir.exist?(policyfile_dir)

  # find existing policies on the server
  server_policies = {}
  policyname = ''

  shell_out("CHEF_LICENSE='accept-no-persist' chef show-policy -c #{configrb}").stdout.each_line do |line|
    line.chomp!
    next if line.empty? || line.start_with?('=') || line =~ /NOT APPLIED/
    if line.start_with?('*')
      server_policies[line.split[1] + line.split[2]] = policyname
    else
      policyname = line
    end
  end

  # only load policies that aren't in the hash produced from the server
  sorted_dir = Dir.entries(policyfile_dir).sort_by { |x| ::File.mtime(policyfile_dir + '/' + x) } # sort by time
  sorted_dir.each do |pfile|
    next unless pfile.end_with?(node['mcs']['policyfile']['lockfiletype'])
    # parse the lockfile and set the appropriate policygroup
    policy_lock = JSON.parse(::File.read(policyfile_dir + '/' + pfile))
    policy_name = policy_lock['name']
    filename = policyfile_dir + '/' + policy_name + '-' + policy_lock['revision_id'] + '.tgz'
    next unless ::File.exist?(filename)
    policy_revision = policy_lock['revision_id'][0, 10]

    policy_group = node['mcs']['policyfile']['group']
    # are they overriding the policy group with an attribute?
    policy_group = policy_lock['default_attributes']['mcs']['policyfile']['group'] unless policy_lock.dig('default_attributes', 'mcs', 'policyfile', 'group').nil?
    policy_group = policy_lock['override_attributes']['mcs']['policyfile']['group'] unless policy_lock.dig('override_attributes', 'mcs', 'policyfile', 'group').nil?
    polindex = policy_group + ':' + policy_revision

    execute "chef push-archive #{policy_group} #{filename}" do
      command "CHEF_LICENSE='accept-no-persist' chef push-archive #{policy_group} #{filename} -c #{configrb}"
      not_if { server_policies[polindex].eql?(policy_name) }
    end
  end
end
