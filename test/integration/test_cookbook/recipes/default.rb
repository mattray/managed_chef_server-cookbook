directory "#{Chef::Config.etc_chef_dir}/trusted_certs"

# self-signed cert for internal A2 testing
cookbook_file "#{Chef::Config.etc_chef_dir}/trusted_certs/inez_bottlebru_sh.crt" do
  sensitive true
  source 'inez_bottlebru_sh.crt'
  mode '0644'
end

# self-signed cert for internal Chef Infra Server
cookbook_file "#{Chef::Config.etc_chef_dir}/trusted_certs/ndnd_bottlebru_sh.crt" do
  sensitive true
  source 'ndnd_bottlebru_sh.crt'
  mode '0644'
end

append_if_no_line 'add ndnd & inez to /etc/hosts' do
  path '/etc/hosts'
  line '10.0.0.2        ndnd ndnd.bottlebru.sh'
  line '10.0.0.10       inez inez.bottlebru.sh'
end
