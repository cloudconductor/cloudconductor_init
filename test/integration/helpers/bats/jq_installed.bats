#! /usr/bin/env bats
#
load test_helper

@test "package jq is installed" {
  run bash -c "yum list installed | grep jq\."
  [ "$status" -eq 0 ]
}

@test "executable jq command is found" {
  run test -x /usr/bin/jq
  [ $status -eq 0 ]
}

@test "executable jq version is 1.4" {
  run jq --version
  assert_success "jq version 1.3"
}
