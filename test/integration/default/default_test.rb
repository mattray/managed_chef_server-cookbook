# # encoding: utf-8

# Inspec test for recipe managed-chef-server::default

# This is an example test, replace it with your own test.
describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe directory('/etc/opscode/managed') do
  it { should exist }
end

# knife.rb
