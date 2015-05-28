#! /usr/bin/env bats

load test_helper

@test "chef.sh file is found" {
  run test -f /etc/profile.d/chef.sh
  if [ $status -ne 0 ]; then
    skip
  fi

  run cat /etc/profile.d/chef.sh
  assert_equal "${lines[0]}" "export PATH=\$PATH:/opt/chefdk/embedded/bin"
}

@test "ruby path is defined" {
  run test -f /etc/profile.d/chef.sh
  if [ $status -ne 0 ]; then
    skip
  fi

  run awk -F: '{print $2}' /etc/profile.d/chef.sh
  assert_equal "${lines[0]}" "/opt/chefdk/embedded/bin"
}
