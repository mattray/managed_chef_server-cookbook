# need the ChefDK for the 'chef' command
chef_ingredient 'chefdk' do
  action :install
  version node['chefdk']['version']
  channel node['chefdk']['channel']
  package_source node['chefdk']['package_source']
end.run_action(:install)
