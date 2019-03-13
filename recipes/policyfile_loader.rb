#
# Cookbook:: managed-chef-server
# Recipe:: policyfile_loader
#

# need the ChefDK for the 'chef' command
include_recipe 'chefdk::default'
node.override['chefdk']['channel'] = :stable

# loads all of the policyfile lock files in a directory into the Chef server
policydir = node['mcs']['policyfile']['dir']
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'

# construct hash of existing policies to skip
show_policy = shell_out("chef show-policy -c #{configrb}")
existing_policies = {}
policyname = ''
show_policy.stdout.each_line do |line|
  next if line.empty?
  next if line.start_with?('=')
  next if line =~ /NOT APPLIED/
  line.chomp!
  if line.start_with?('*')
    policygroup = line.split[1]
    short_rev = line.split[2]
    existing_policies[policygroup + short_rev] = policyname
  else
    policyname = line
  end
end

# find the local policyfiles
unless policydir.nil?
  Dir.foreach(policydir) do |pfile|
    next unless pfile.end_with?(node['mcs']['policyfile']['lockfiletype'])

    # parse the JSON file, get the revision ID
    plock = JSON.parse(File.read(policydir + '/' + pfile))
    revision = plock['revision_id']
    policyname = plock['name']
    short_rev = revision[0, 10]
    # match the right policyfile archive based on name in lock file
    filename = policydir + '/' + policyname + '-' + revision + '.tgz'

    policygroup = node['mcs']['policyfile']['group']
    # if the policyfile sets the group, use that value
    policygroup = plock['default_attributes']['mcs']['policyfile']['group'] unless plock.dig('default_attributes', 'mcs', 'policyfile', 'group').nil?
    policygroup = plock['override_attributes']['mcs']['policyfile']['group'] unless plock.dig('override_attributes', 'mcs', 'policyfile', 'group').nil?
    polindex = policygroup + ':' + short_rev

    # push the archive to the policygroup under the policy name
    execute "chef push-archive #{policygroup} #{filename}" do
      command "chef push-archive #{policygroup} #{filename} -c #{configrb}"
      not_if { existing_policies[polindex] }
    end
  end
end
