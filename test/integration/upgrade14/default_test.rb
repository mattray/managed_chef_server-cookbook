# InSpec test for recipe managed_chef_server::upgrade

if os.debian?
  describe file '/tmp/kitchen/cache/managed_chef_server.upgraded' do
    it { should exist }
    its('content') { should match /^chef-server-core_14.2.2-1_amd64.deb$/ }
  end
  describe command('apt list --installed | grep chef-server-core') do
    its('stdout') { should match /^chef-server-core/ }
    its('stdout') { should match /14.2.2-1/ }
    its('stdout') { should match /amd64/ }
  end
elsif os.redhat?
  describe file '/tmp/kitchen/cache/managed_chef_server.upgraded' do
    it { should exist }
    its('content') { should match /^chef-server-core-14.2.2-1.el7.x86_64.rpm$/ }
  end
  describe command('rpm -aq | grep chef-server-core') do
    its('stdout') { should match /^chef-server-core-14.2.2-1.el7.x86_64$/ }
  end
end
