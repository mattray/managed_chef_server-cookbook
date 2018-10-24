name "essex"
description "Defines the network and database settings you're going to use with OpenStack. The networks will be used in the libraries provided by the osops-utils cookbook. This example is for FlatDHCP with 2 physical networks."

override_attributes(
  "glance" => {
    "image_upload" => true,
    "images" => ["precise","cirros"],
    "image" => {
      "cirros" => "http://hypnotoad/cirros-0.3.0-x86_64-disk.img",
      "precise" => "http://hypnotoad/precise-server-cloudimg-amd64.tar.gz"
    }
  },
  "mysql" => {
    "allow_remote_root" => true,
    "root_network_acl" => "%"
  },
  "osops_networks" => {
    "public" => "10.0.0.0/24",
    "management" => "10.0.0.0/24",
    "nova" => "10.0.0.0/24"
  },
  "nova" => {
    "network" => {
      "fixed_range" => "192.168.100.0/24",
      "public_interface" => "eth0"
    },
    "networks" => [
      {
        "label" => "public",
        "ipv4_cidr" => "192.168.100.0/24",
        "num_networks" => "1",
        "network_size" => "255",
        "bridge" => "br100",
        "bridge_dev" => "eth0",
        "dns1" => "8.8.8.8",
        "dns2" => "8.8.4.4"
      }
    ]
  }
  )

cookbook_versions({
    "apache2"=>"= 1.4.2",
    "apt"=>"= 1.8.4",
    "aws"=>"= 0.100.6",
    "build-essential"=>"= 1.3.4",
    "ntp"=>"= 1.3.2",
    "openssh"=>"= 1.1.4",
    "openssl"=>"= 1.0.0",
    "postgresql"=>"= 2.2.0",
    "selinux"=>"= 0.5.6",
    "xfs"=>"= 1.1.0",
    "yum"=>"= 2.1.0",
    "erlang"=>"= 1.1.2",
    "mysql"=>"= 2.1.2",
    "rabbitmq"=>"= 1.8.0",
    "database"=>"= 1.3.12",
    "omnibus_updater"=>"= 0.1.2",
    "lxc"=>"= 0.1.0",
    "sysctl"=>"= 0.1.2",
    "osops-utils"=>"= 1.0.6",
    "mysql-openstack"=>"= 1.0.4",
    "rabbitmq-openstack"=>"= 1.0.4",
    "keystone"=>"= 2012.1.1",
    "glance"=>"= 2012.1.1",
    "nova"=>"= 2012.1.2",
    "horizon"=>"= 2012.1.1"
  })
