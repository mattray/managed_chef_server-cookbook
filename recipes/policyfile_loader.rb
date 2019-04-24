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

existing_policies = {}
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
      end
    end
    node.run_state['existing_policies'] = existing_policies
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
      node.run_state['existing_policies'].delete(polindex)
    end
  end
end

# after the above block completes, the existing_policies hash only contains policies that don't exist in the policydir
# so we delete them if that's an option

ruby_block 'remove unused policies' do
  block do
    node.run_state['existing_policies'].each do |_key, pol|
      print "\nDeleting unused policy #{pol}"
      shell_out("chef delete-policy #{pol} -c #{configrb}")
    end
  end
  only_if { node['mcs']['policyfile']['purge'] }
  not_if { node.run_state['existing_policies'].empty? }
end
