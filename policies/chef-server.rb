name "chef-server"
run_list "managed-chef-server::default"
named_run_list "everything", "managed-chef-server::default","managed-chef-server::backup","managed-chef-server::maintenance"
default_source :supermarket
cookbook "chef-server" , ">= 5.5.2"
cookbook "managed-chef-server" , path: ".."
