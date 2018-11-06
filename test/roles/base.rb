name "base"
description "Base role applied to all nodes."
run_list(
  "recipe[apt]",
  "recipe[nagios::client]"
)

default_attributes(
  "nagios" => {
    "server_role" => "monitoring"
  }
)
