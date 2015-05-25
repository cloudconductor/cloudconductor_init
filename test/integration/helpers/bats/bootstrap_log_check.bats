#! /usr/bin/env bats

load test_helper

@test "bootstrap.log file is found" {
  run test -f /opt/cloudconductor/logs/bootstrap.log
  assert_success
}

@test "bootstrap.log check" {
  run cat /opt/cloudconductor/logs/bootstrap.log
  assert_equal "$(echo ${lines[0]} | awk -F ] '{print $2}')" " INFO: set chefdk_path."
  assert_equal "$(echo ${lines[1]} | awk -F ] '{print $2}')" " INFO: install cloud_conductor_utils."
  assert_equal "$(echo ${lines[2]} | awk -F ] '{print $2}')" " INFO: install cloud_conductor_utils has finished successfully."
  assert_equal "$(echo ${lines[3]} | awk -F ] '{print $2}')" " INFO: execute berks."
  assert_equal "$(echo ${lines[4]} | awk -F ] '{print $2}')" " INFO: berks has finished successfully."
  assert_equal "$(echo ${lines[5]} | awk -F ] '{print $2}')" " INFO: execute chef-solo."
  assert_equal "$(echo ${lines[6]} | awk -F ] '{print $2}')" " INFO: chef-solo has finished successfully."
  assert_equal "$(echo ${lines[7]} | awk -F ] '{print $2}')" " INFO: execute event-handler with setup event."
  assert_equal "$(echo ${lines[8]} | awk -F ] '{print $2}')" " INFO: event-handler has finished successfully."
}
