#! /usr/bin/env bats

load test_helper

@test "server entry" {
  hostname=`hostname`
  ipaddress=`hostname -i`

  source /opt/cloudconductor/config
  token=${CONSUL_SECRET_KEY}
  roles=${ROLE}

  run bash -c "curl -s --noproxy localhost http://localhost:8500/v1/kv/cloudconductor/servers/${hostname}?raw\&token=${token} | jq -r '.private_ip'"
  assert_success "${ipaddress}"

  run bash -c "curl -s --noproxy localhost http://localhost:8500/v1/kv/cloudconductor/servers/${hostname}?raw\&token=${token} | jq -r -c '.roles | .[]'"
  assert_success "$(echo ${roles} | tr -s ',' '\n' )"
}
