#! /usr/bin/env bats

load test_helper

@test "consul config acl_datacenter is contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_datacenter"
  assert_success

  run jq -r '.acl_datacenter' /etc/consul.d/default.json
  assert_success "dc1"
}

@test "consul config acl_default_policy is contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_default_policy"
  assert_success

  run jq -r '.acl_default_policy' /etc/consul.d/default.json
  assert_success "deny"
}

@test "consul config acl_master_token is contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_master_token"
  assert_success

  source /opt/cloudconductor/config
  token=${CONSUL_SECRET_KEY}

  run jq -r '.acl_master_token' /etc/consul.d/default.json
  assert_success "${token}"
}

@test "consul config acl_token is contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep acl_token"
  assert_success

  run jq -r '.acl_token' /etc/consul.d/default.json
  assert_success "anonymous"
}

@test "consul config encrypt is contains" {
  run bash -c "jq -r 'keys | .[]' /etc/consul.d/default.json | grep encrypt"
  assert_success

  source /opt/cloudconductor/config
  token=${CONSUL_SECRET_KEY}

  run jq -r '.encrypt' /etc/consul.d/default.json
  assert_success "${token}"
}
