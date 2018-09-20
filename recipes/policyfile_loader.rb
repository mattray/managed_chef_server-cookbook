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

# find the local policyfiles
Dir.foreach(policydir) do |pfile|
  next unless pfile.end_with?('.lock.json')

  # parse the filename, drop the .lock.json
  policy = pfile.sub(/\.lock\.json$/, '')

  # parse the JSON file, get the revision ID
  plock = JSON.parse(File.read(policydir + '/' + pfile))
  revision = plock['revision_id']
  policyname = plock['name']
  short_rev = revision[0, 9]
  # match the right policyfile archive
  filename = policydir + '/' + policy + '-' + revision + '.tgz'
  configrb = node['mcs']['managed_user']['dir'] + '/config.rb'

  # push the archive to the policygroup, currently the name of the policyfile
  execute "chef push-archive #{policyname} #{filename}-#{revision}.tgz" do
    command "chef push-archive #{policyname} #{filename} -c #{configrb}"
    # add a guard to check if chef show-policy
    not_if "chef show-policy #{policy} -c #{kniferb} | grep '* #{policy}' | grep #{short_rev}"
  end
end
