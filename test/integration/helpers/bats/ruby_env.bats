#! /usr/bin/env bats

load test_helper

@test "chef.sh file is found" {
  run test -f /etc/profile.d/chef.sh
  if [ $status -ne 0 ]; then
    skip
  fi

  run test -d /opt/chefdk
  if [ $status -eq 0 ]; then
    chef_root="/opt/chefdk"
  else
    chef_root="/opt/chef"
  fi

  run cat /etc/profile.d/chef.sh
  assert_equal "${lines[0]}" "export PATH=\$PATH:${chef_root}/embedded/bin"
}

@test "ruby path is defined" {
  run test -f /etc/profile.d/chef.sh
  if [ $status -ne 0 ]; then
    skip
  fi

  run test -d /opt/chefdk
  if [ $status -eq 0 ]; then
    chef_root="/opt/chefdk"
  else
    chef_root="/opt/chef"
  fi

  run awk -F: '{print $2}' /etc/profile.d/chef.sh
  assert_equal "${lines[0]}" "${chef_root}/embedded/bin"
}
