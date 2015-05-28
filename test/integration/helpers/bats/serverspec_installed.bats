#! /usr/bin/env bats

load test_helper

@test "gem serverspec is found" {
  run test -f /etc/profile.d/chef.sh
  if [ $status -ne 0 ]; then
    skip
  fi

  run bash -c "chef gem list | grep serverspec"
  assert_success
}
