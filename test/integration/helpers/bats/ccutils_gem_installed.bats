#! /usr/bin/env bats

load test_helper

@test "cloud_conductor_utils gem is installed" {
  run bash -c 'chef gem list | grep cloud_conductor_utils'
  assert_success "cloud_conductor_utils (1.0.0)"
}
