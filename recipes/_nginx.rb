# tweak settings to make chef nginx run as opscode rather than as root
# this is done by granting setcap privilege to the the chef nginx binary
# (so that it can open up privileged port 443) then changing the
# system startup of chef nginx to run as opscode user and setting
# ownership of log directories so opscode can write to them

directory '/opt/opscode/sv/nginx' do
  recursive true
end

cookbook_file '/opt/opscode/sv/nginx/run' do
  source 'nginx.run'
  cookbook 'managed_chef_server'
  sensitive true
  mode '0755'
end

execute 'chown nginx logs' do
  command 'chown -R opscode:opscode /var/log/opscode/nginx /opt/opscode/embedded/nginx'
  only_if 'ls -al /var/log/opscode/nginx | grep root' || 'ls -al /opt/opscode/embedded/nginx | grep root'
end

execute 'setcap cap_net_bind_service=ep nginx' do
  command '/sbin/setcap cap_net_bind_service=ep /opt/opscode/embedded/sbin/nginx'
  not_if '/sbin/setcap -v cap_net_bind_service=ep /opt/opscode/embedded/sbin/nginx'
end

execute 'chef-server-ctl restart nginx' do
  action :nothing
  subscribes :run, 'execute[setcap cap_net_bind_service=ep nginx]', :immediately
end
