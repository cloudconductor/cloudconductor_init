#! /usr/bin/env bats

load test_helper

@test "consul config acl_datacenter is not contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_datacenter"
  assert_failure
}

@test "consul config acl_default_policy is not contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_default_policy"
  assert_failure
}

@test "consul config acl_master_token is not contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_master_token"
  assert_failure
}

@test "consul config acl_token is not contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_token"
  assert_failure
}

@test "consul config encrypt is not contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep encrypt"
  assert_failure
}
