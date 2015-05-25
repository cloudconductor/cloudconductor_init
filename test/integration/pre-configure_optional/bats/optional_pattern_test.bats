#! /usr/bin/env bats

load test_helper

@test "optional pattern is cloned" {

  patterns=($(curl -s --noproxy localhost http://localhost:8500/v1/kv/cloudconductor/parameters?raw\&token=UWHlGY3fjIqpcDxZdVC4yw== | jq -r '.cloudconductor.patterns | .[] | select(.type == "optional") | .name'))

  for pattern in ${patterns[@]}
  do
    run test -d /opt/cloudconductor/patterns/${pattern}
    assert_success
  done
}

@test "optional pattern's logs dir is found" {

  patterns=($(curl -s --noproxy localhost http://localhost:8500/v1/kv/cloudconductor/parameters?raw\&token=UWHlGY3fjIqpcDxZdVC4yw== | jq -r '.cloudconductor.patterns | .[] | select(.type == "optional") | .name'))

  for pattern in ${patterns[@]}
  do
    run test -L /opt/cloudconductor/logs/${pattern}
    assert_success

    run readlink -f /opt/cloudconductor/logs/${pattern}
    assert_success /opt/cloudconductor/patterns/${pattern}/logs
  done

}

@test "optional pattern's service entry to consul" {

  patterns=($(curl -s --noproxy localhost http://localhost:8500/v1/kv/cloudconductor/parameters?raw\&token=UWHlGY3fjIqpcDxZdVC4yw== | jq -r '.cloudconductor.patterns | .[] | select(.type == "optional") | .name'))

  for pattern in ${patterns[@]}
  do
    if [ -d /opt/cloudconductor/patterns/${pattern}/services ] ; then
      for json_file in $(ls -A /opt/cloudconductor/patterns/${pattern}/services/all/**/*.json)
      do
        assert_file_exists /etc/consul.d/$(basename $json_file)
        run cat $json_file
        assert_success "$(cat /etc/consul.d/$(basename ${json_file}))"
      done
    fi
  done

}
