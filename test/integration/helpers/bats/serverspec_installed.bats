#! /usr/bin/env bats

@test "gem serverspec is found" {
  run bash -c "chef gem list | grep serverspec"
  echo $output
  [ $status -eq 0 ]
}
