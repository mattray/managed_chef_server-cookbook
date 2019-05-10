#
# Cookbook:: managed-chef-server
# Recipe:: policyfile_loader
#

# need the ChefDK for the 'chef' command
chef_ingredient 'chefdk' do
  action :install
  version node['chefdk']['version']
  channel node['chefdk']['channel']
  package_source node['chefdk']['package_source']
end.run_action(:install)

# loads all of the policyfile lock files in a directory into the Chef server
policydir = node['mcs']['policyfile']['dir']
configrb = node['mcs']['managed_user']['dir'] + '/config.rb'

return if policydir.nil? || policydir.empty?

# policy revisions
existing_policies = {}
# policy names
existing_names = []

policyname = ''

# construct hash of existing policies
ruby_block 'inspect existing policies' do
  block do
    shell_out("chef show-policy -c #{configrb}").stdout.each_line do |line|
      line.chomp!
      next if line.empty? || line.start_with?('=') || line =~ /NOT APPLIED/
      if line.start_with?('*')
        existing_policies[line.split[1] + line.split[2]] = policyname
      else
        policyname = line
        existing_names << policyname
      end
    end
    node.run_state['existing_policies'] = existing_policies
    node.run_state['existing_names'] = existing_names
    # puts "NNNN #{existing_names}"
  end
end

# load policies that aren't in the hash produced above
ruby_block 'load new policies' do
  block do
    Dir.foreach(policydir) do |pfile|
      next unless pfile.end_with?(node['mcs']['policyfile']['lockfiletype'])
      plock = JSON.parse(File.read(policydir + '/' + pfile))
      filename = policydir + '/' + plock['name'] + '-' + plock['revision_id'] + '.tgz'
      policygroup = node['mcs']['policyfile']['group']
      policygroup = plock['default_attributes']['mcs']['policyfile']['group'] unless plock.dig('default_attributes', 'mcs', 'policyfile', 'group').nil?
      policygroup = plock['override_attributes']['mcs']['policyfile']['group'] unless plock.dig('override_attributes', 'mcs', 'policyfile', 'group').nil?
      polindex = policygroup + ':' + plock['revision_id'][0, 10]
      print "\nPushing policy #{plock['name']} #{plock['revision_id'][0, 10]} to policy group #{policygroup}" unless node.run_state['existing_policies'][polindex]
      shell_out("chef push-archive #{policygroup} #{filename} -c #{configrb}") unless node.run_state['existing_policies'][polindex]
      node.run_state['existing_names'].delete(plock['name']) # any policyname encountered in the policydir is to be kept regardless of revision
    end
  end
end

# after the above block completes, the existing_names array only contains policies that weren't found in the policydir
# so we may delete them (if that's an option)

ruby_block 'remove unused policies' do
  block do
    node.run_state['existing_names'].each do |policy|
      print "\nDeleting unused policy #{policy}"
      shell_out("chef delete-policy #{policy} -c #{configrb}")
    end
    # we could do this here or in the maintenance recipe
    # shell_out("chef clean-policy-revisions -c #{configrb}")
  end
  only_if { node['mcs']['policyfile']['purge'] }
  not_if { node.run_state['existing_names'].empty? }
end
