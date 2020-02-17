#
# Cookbook:: managed_chef_server
# Recipe:: _data_collector
#

# if using Automate, configure data collection
# https://automate.chef.io/docs/data-collection/#setting-up-data-collection-on-chef-server-versions-1214-and-higher
token = node['mcs']['data_collector']['token']
unless token.nil?
  execute 'chef-server-ctl set-secret data_collector token' do
    command "chef-server-ctl set-secret data_collector token '#{token}'"
    not_if "chef-server-ctl show-secret data_collector token | grep '#{token}'"
  end

  # Please restart these services: nginx, opscode-erchef
  execute 'chef-server-ctl restart nginx' do
    action :nothing
    subscribes :run, 'execute[chef-server-ctl set-secret data_collector token]', :immediately
  end

  execute 'chef-server-ctl restart opscode-erchef' do
    action :nothing
    subscribes :run, 'execute[chef-server-ctl set-secret data_collector token]', :immediately
    notifies :reconfigure, 'chef_ingredient[chef-server]', :immediately
  end
end
