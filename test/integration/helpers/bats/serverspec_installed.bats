#! /usr/bin/env bats

load test_helper

@test "gem serverspec is found" {
  run test -f /etc/profile.d/chef.sh
  if [ $status -ne 0 ]; then
    skip
  fi

  path=$(awk -F: '{print $2}' /etc/profile.d/chef.sh)
  lib_path=$(cd ${path}/../lib ; pwd)

  run bash -c "ls -al \"${lib_path}/ruby/gems/2.1.0/gems/\" | grep serverspec"
  assert_success
}
