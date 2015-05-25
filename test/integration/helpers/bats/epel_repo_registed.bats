#! /usr/bin/env bats

@test "epel.repo file is exists" {
  run test -f /etc/yum.repos.d/epel.repo
  [ $status -eq 0 ]
}

#@test "epel.repo is disabled" {
#  run grep "enabled=1" /etc/yum.repos.d/epel.repo
#  [ $status -ne 0 ]
#}
