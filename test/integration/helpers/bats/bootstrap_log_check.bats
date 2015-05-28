#! /usr/bin/env bats

load test_helper

@test "bootstrap.log file is found" {
  run test -f /opt/cloudconductor/logs/bootstrap.log
  assert_success
}

@test "bootstrap.log Error is not found" {
  run grep "ERROR|FATAL" /opt/cloudconductor/logs/bootstrap.log
  assert_failure
}
