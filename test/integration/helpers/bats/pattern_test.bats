#! /usr/bin/env bats

load test_helper

@test "pattern is cloned" {
  assert_directory_exists /opt/cloudconductor/patterns/*_pattern
}

@test "pattern logs dir is found" {
  for pattern in `ls -A /opt/cloudconductor/patterns/ | grep .*_pattern`
  do
    type=$(cat /opt/cloudconductor/patterns/${pattern}/metadata.yml | grep type: | awk -F: '{print $2}' | tr -d ' "')
    if [ "$type" != "platform" ] ; then
      continue
    fi

    assert_directory_exists /opt/cloudconductor/patterns/${pattern}/logs

    assert_directory_exists /opt/cloudconductor/logs/${pattern}/

    run test -L /opt/cloudconductor/logs/${pattern}
    assert_success

    run readlink -f /opt/cloudconductor/logs/${pattern}
    assert_success /opt/cloudconductor/patterns/${pattern}/logs
  done
}

@test "pattern log file is found" {

  roles=${ROLE}

  if [[ -n "$roles" ]] ||[[ -f /opt/cloudconductor/config ]] ; then
    roles=$(grep ROLE /opt/cloudconductor/config | awk -F= '{print $2}')
  fi

  if [[ -n "$roles" ]] || [[ -f /tmp/kitchen/bootstrap.sh ]] ; then
    roles=$(grep ROLE /tmp/kitchen/bootstrap.sh | awk -F= '{print $2}')
  fi

  [ -n $roles ]

  for pattern in $(ls -A /opt/cloudconductor/patterns/ | grep .*_pattern)
  do
    type=$(cat /opt/cloudconductor/patterns/${pattern}/metadata.yml | grep type: | awk -F: '{print $2}' | tr -d ' "')
    if [ "$type" != "platform" ] ; then
      continue
    fi

    for role in $(echo ${roles} | tr -s ',' ' ')
    do
      assert_file_exists /opt/cloudconductor/logs/${pattern}/${pattern}_${role}_chef-solo.log
    done
  done
}

@test "pattern's service entry to consul" {

  roles=${ROLE}

  if [[ -n "$roles" ]] ||[[ -f /opt/cloudconductor/config ]] ; then
    roles=$(grep ROLE /opt/cloudconductor/config | awk -F= '{print $2}')
  fi

  if [[ -n "$roles" ]] || [[ -f /tmp/kitchen/bootstrap.sh ]] ; then
    roles=$(grep ROLE /tmp/kitchen/bootstrap.sh | awk -F= '{print $2}')
  fi

  [ -n $roles ]

  for pattern in $(ls -A /opt/cloudconductor/patterns/ | grep .*_pattern)
  do
    type=$(cat /opt/cloudconductor/patterns/${pattern}/metadata.yml | grep type: | awk -F: '{print $2}' | tr -d ' "')
    if [ "$type" != "platform" ] ; then
      continue
    fi

    for role in $(echo ${roles} | tr -s ',' ' ')
    do
      if [ -d /opt/cloudconductor/patterns/${pattern}/services ] ; then
         for json_file in $(ls -A /opt/cloudconductor/patterns/${pattern}/services/${roles})
         do
           assert_file_exists /etc/consul.d/${json_file}
           run cat /opt/cloudconductor/patterns/${pattern}/services/${roles}/${json_file}
           assert_success "$(cat /etc/consul.d/${json_file})"
         done
      fi
    done
  done
}
