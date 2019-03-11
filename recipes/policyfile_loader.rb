#
# Cookbook:: managed-chef-server
# Recipe:: policyfile_loader
#

# need the ChefDK for the 'chef' command
include_recipe 'chefdk::default'
node.override['chefdk']['channel'] = :stable

# loads all of the policyfile lock files in a directory into the Chef server
# chef install base.rb     # generates base.lock.json
# chef export base.rb . -a # generates base-VERSION.tgz
# chef push-archive POLICY_GROUP base-VERSION.tgz -c config_file --debug

policydir = node['mcs']['policyfile']['dir']
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'

# construct hash of existing policies
poldump = Mixlib::ShellOut.new("chef show-policy -c #{configrb} | egrep -v -e '^$|^=====|NOT APPLIED'")
poldump.run_command
policies = {}
pol = ''
poldump.stdout.each_line do |line|
  if line.include? '*'
    pgroup = line.split[1]
    prevision = line.split[2]
    policies[pgroup + prevision] = pol
  else
    pol = line.to_str.chomp
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

    # push the archive to the policygroup under the policy name
    execute "chef push-archive #{policygroup} #{filename}" do
      command "chef push-archive #{policygroup} #{filename} -c #{configrb}"
      # add a guard to check if chef show-policy indicates the policy is already installed
      polindex = policygroup + ':' + short_rev
      only_if { policies[polindex].nil? }
    end
  end
end
