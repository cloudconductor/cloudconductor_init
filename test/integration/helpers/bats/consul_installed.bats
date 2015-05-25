#! /usr/bin/env bats
#
load test_helper

@test "executable consul command is found" {
  run test -x /usr/local/bin/consul
  assert_success
}

@test "consul version is v0.5.0" {
  run /usr/local/bin/consul --version
  assert_success
  assert_equal "${lines[0]}" "Consul v0.5.0"
}

@test "consul config dir is exists" {
  run test -d /etc/consul.d
  assert_success
}

@test "consul config file is found" {
  run test -f /etc/consul.d/default.json
  assert_success
}

@test "consul sysconfig file is found" {
  run test -f /etc/sysconfig/consul
  assert_success

  run cat /etc/sysconfig/consul
  assert_success "GOMAXPROCS=1"
}

@test "consul data dir is exists" {
  run test -d /var/lib/consul
  assert_success
}

@test "consul service is found" {
  run test -x /etc/init.d/consul
  assert_success
}

@test "consul event_handlers dir is exists" {
  run test -d /opt/consul/event_handlers
  assert_success
}

@test "consul event_handler file is exists and runnable" {
  run test -x /opt/consul/event_handlers/event-handler
  assert_success
}

@test "consul action_runner.rb file is exists" {
  run test -f /opt/consul/event_handlers/action_runner.rb
  assert_success
}

@test "consul.key file is found" {
  run test -f /etc/pki/tls/private/consul.key
  assert_success
}

@test "consul event watches.json file is found" {
  run test -f /etc/consul.d/watches.json
  assert_success
}

@test "consul event is watched " {

  for name in `(setup configure deploy backup restore spec)`
  do
    run bash -c "cat /etc/consul.d/watches.json | jq -c '.watches | .[] | [.name, .type, .handler]' | grep ${name}"
    assert_success "[\"${name}\",\"event\",\"/opt/consul/event_handlers/event-handler ${name}\"]"
  done
}
