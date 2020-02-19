# encoding: utf-8

# Inspec test for recipe managed_chef_server::data_bag_loader

# check output of knife commands

describe command('knife data bag list -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^users$/ }
  its('stdout') { should match /^tests$/ }
end

describe command('knife data bag show users -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should_not match /^user 1$/ } # this one should be pruned
  its('stdout') { should match /^user2$/ }
  its('stdout') { should match /^user3$/ }
  its('stdout') { should match /^user4$/ }
end

# this one is updated by the data_bag_loader
describe command('knife data bag show users user2 -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^name: User 2$/ }
end

describe command('knife data bag show users user3 -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^name: User Three$/ }
end

describe command('knife data bag show tests -c /etc/opscode/managed/test_org/config.rb') do
  its('stdout') { should match /^test1$/ }
  its('stdout') { should match /^test2$/ }
  its('stdout') { should match /^test3$/ }
  its('stdout') { should match /^test4$/ }
  its('stdout') { should match /^test5$/ }
  its('stdout') { should match /^test6$/ }
  its('stdout') { should match /^test7$/ }
  its('stdout') { should match /^test8$/ }
  its('stdout') { should match /^test9$/ }
  its('stdout') { should match /^test10$/ }
  its('stdout') { should match /^test11$/ }
  its('stdout') { should match /^test12$/ }
  its('stdout') { should match /^test13$/ }
  its('stdout') { should match /^test14$/ }
  its('stdout') { should match /^test15$/ }
  its('stdout') { should match /^test16$/ }
  its('stdout') { should match /^test17$/ }
  its('stdout') { should match /^test18$/ }
  its('stdout') { should match /^test19$/ }
  its('stdout') { should match /^test20$/ }
  its('stdout') { should match /^test21$/ }
  its('stdout') { should match /^test22$/ }
  its('stdout') { should match /^test23$/ }
  its('stdout') { should match /^test24$/ }
  its('stdout') { should match /^test25$/ }
  its('stdout') { should match /^test26$/ }
  its('stdout') { should match /^test27$/ }
  its('stdout') { should match /^test28$/ }
  its('stdout') { should match /^test29$/ }
  its('stdout') { should match /^test30$/ }
  its('stdout') { should match /^test31$/ }
  its('stdout') { should match /^test32$/ }
  its('stdout') { should match /^test33$/ }
  its('stdout') { should match /^test34$/ }
  its('stdout') { should match /^test35$/ }
  its('stdout') { should match /^test36$/ }
  its('stdout') { should match /^test37$/ }
  its('stdout') { should match /^test38$/ }
  its('stdout') { should match /^test39$/ }
  its('stdout') { should match /^test40$/ }
  its('stdout') { should match /^test41$/ }
  its('stdout') { should match /^test42$/ }
  its('stdout') { should match /^test43$/ }
  its('stdout') { should match /^test44$/ }
  its('stdout') { should match /^test45$/ }
  its('stdout') { should match /^test46$/ }
  its('stdout') { should match /^test47$/ }
  its('stdout') { should match /^test48$/ }
  its('stdout') { should match /^test49$/ }
  its('stdout') { should match /^test50$/ }
  its('stdout') { should match /^test51$/ }
  its('stdout') { should match /^test52$/ }
  its('stdout') { should match /^test53$/ }
  its('stdout') { should match /^test54$/ }
  its('stdout') { should match /^test55$/ }
  its('stdout') { should match /^test56$/ }
  its('stdout') { should match /^test57$/ }
  its('stdout') { should match /^test58$/ }
  its('stdout') { should match /^test59$/ }
  its('stdout') { should match /^test60$/ }
  its('stdout') { should match /^test61$/ }
  its('stdout') { should match /^test62$/ }
  its('stdout') { should match /^test63$/ }
  its('stdout') { should match /^test64$/ }
  its('stdout') { should match /^test65$/ }
  its('stdout') { should match /^test66$/ }
  its('stdout') { should match /^test67$/ }
  its('stdout') { should match /^test68$/ }
  its('stdout') { should match /^test69$/ }
  its('stdout') { should match /^test70$/ }
  its('stdout') { should match /^test71$/ }
  its('stdout') { should match /^test72$/ }
  its('stdout') { should match /^test73$/ }
  its('stdout') { should match /^test74$/ }
  its('stdout') { should match /^test75$/ }
  its('stdout') { should match /^test76$/ }
  its('stdout') { should match /^test77$/ }
  its('stdout') { should match /^test78$/ }
  its('stdout') { should match /^test79$/ }
  its('stdout') { should match /^test80$/ }
  its('stdout') { should match /^test81$/ }
  its('stdout') { should match /^test82$/ }
  its('stdout') { should match /^test83$/ }
  its('stdout') { should match /^test84$/ }
  its('stdout') { should match /^test85$/ }
  its('stdout') { should match /^test86$/ }
  its('stdout') { should match /^test87$/ }
  its('stdout') { should match /^test88$/ }
  its('stdout') { should match /^test89$/ }
  its('stdout') { should match /^test90$/ }
  its('stdout') { should match /^test91$/ }
  its('stdout') { should match /^test92$/ }
  its('stdout') { should match /^test93$/ }
  its('stdout') { should match /^test94$/ }
  its('stdout') { should match /^test95$/ }
  its('stdout') { should match /^test96$/ }
  its('stdout') { should match /^test97$/ }
  its('stdout') { should match /^test98$/ }
  its('stdout') { should match /^test99$/ }
  its('stdout') { should match /^test100$/ }
  its('stdout') { should match /^aye$/ }
end
