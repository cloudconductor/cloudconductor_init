#! /usr/bin/env bats

@test "executable hping3 command is found" {
  run test -x /usr/sbin/hping3
  [ $status -eq 0 ]
}
