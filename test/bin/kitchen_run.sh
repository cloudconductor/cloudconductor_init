#! /bin/bash

PROGNAME=$(basename $0)

usage() {
  echo "Usage: $PROGNAME <command> [INSTANCE|REGEXP|all]"
  echo
  echo "Command:"
  echo "  create  "
  echo "  converge"
  echo "  setup   "
  echo "  verify  "
  echo "  destroy "
  echo "  test    "
  echo "  list    "
}

package_expect_install() {
  if ! which expect ; then
    sudo yum -y install expect
  fi
}

func_destroy() {
  instance=$1
  shift

  rm -f ./bootstrap.sh
  kitchen destroy ${instance} $@ || exit $?
}

func_create() {
  instance=$1
  shift

  kitchen create ${instance} $@ || exit $?
}


func_init() {
  instance=$1
  shift

  rm -f ./bootstrap.sh

  json_data=$(kitchen diagnose ${instance} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)")

  last_action=$(echo ${json_data} | jq -r ".instances.\"${instance}\".state_file.last_action")
  if [ "${last_action}" == "null" ] ; then
    func_create $instance $@ || exit $?
  fi

  json_data=$(kitchen diagnose ${instance} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)")
  data=($(echo ${json_data} | jq ".instances.\"${instance}\"" | jq -r '.state_file.hostname, .state_file.port, .driver.username, .driver.password, .provisioner.root_path, .provisioner.kitchen_root'))

  hostname=${data[0]}
  port=${data[1]}
  username=${data[2]}
  password=${data[3]}
  root_path=${data[4]}
  kitchen_root=${data[5]}

  deploy_path=/opt/cloudconductor

  kitchen exec ${instance} -c "sudo rm -r -f ${root_path}" $@ || exit $?
  #kitchen exec ${instance} -c "mkdir -p ${root_path}" $@ || exit $?

  expect -c "
  spawn scp -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -o IdentitiesOnly=yes \
    -o LogLevel=VERBOSE \
    -P ${port} -rq ${kitchen_root} ${username}@${hostname}:${root_path}
  expect {
    default { exit 1 }
    \"password\" {
      send \"${password}\\n\"
      interact
    }
  }
  catch wait result
  set STATUS [ lindex \$result 3 ]
  exit \$STATUS
  "
  [ $? -eq 0 ] || exit $?

  kitchen exec ${instance} -c "sudo rm -r -f ${deploy_path}" $@ || exit $?
  #kitchen exec ${instance} -c "sudo mkdir -p ${deploy_path}" $@ || exit $?
  kitchen exec ${instance} -c "sudo cp -r ${root_path} ${deploy_path}" $@ || exit $?
}

func_converge() {
  instance=$1
  shift

  func_init ${instance} $@

  data_all=$(kitchen diagnose ${instance} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)" | jq ".instances.\"${instance}\"")
  run_list=$(echo ${data_all} | jq '.provisioner.run_list | .[]')
  data=($(echo ${data_all} | jq -r '.provisioner.attributes | .cc_pattern, .cc_revision, .cc_role, .cc_token'))

  pattern=${data[0]}
  revision=${data[1]}
  role=${data[2]}
  token=${data[3]}


  {
  echo "#! /bin/bash ${bash_param}"
  echo 'LANG=en_US.UTF-8'
  echo "param=\"${bash_param}\""

  echo "root_path=${deploy_path}"
  echo 'cd ${root_path}'

  echo "export PATTERN_NAME=${pattern}"
  echo "export PATTERN_URL=\"https://github.com/cloudconductor-patterns/${pattern}.git\""
  echo "export PATTERN_REVISION=${revision}"
  echo "export ROLE=${role}"
  if [ "${token}" != "" -a "${token}" != "null" ]; then
    echo "export CONSUL_SECRET_KEY=${token}"
  fi

  echo "run_list=(${run_list})"
  echo 'for file in ${run_list[@]}'
  echo 'do'
  echo '  bash ${param} ${file}'
  echo 'done'
  } > ./bootstrap.sh

  kitchen converge ${instance} $@ || exit $?
}

instance_list() {
  json_data=$(kitchen diagnose ${1} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)")
  echo ${json_data} | jq  -r '.instances | keys | .[]'
}

func_test() {
  func_destroy $@

  func_create $@

#instance='prebuild-centos-6'
  instance=$1
  shift


  json_data=$(kitchen diagnose ${instance} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)")

  instances=($(echo ${json_data} | jq  -r '.instances | keys | .[]'))

  for instance in ${instances[@]}
  do
    func_converge ${instance} $@
  done
}

log_level() {
  #(debug, info, warn, error, fatal)
  case "$1" in
    'debug' )
      set -ex
      bash_param+=( "-ex" )
      ;;
    'info' )
      ;;
    'warn' )
      ;;
    'error' )
      ;;
    'fatal' )
      ;;
    *)
      return 1
      ;;
  esac

  ki_param+=( "-l ${1}" )
}

cmd_chk() {
  case "$1" in
    'create'|'converge'|'setup'|'verify'|'destroy'|'test'|'list')
      ;;
    *)
      return 1
      ;;
  esac
}

for OPT in "$@"
do
  case "$OPT" in
    '-h'|'--help' )
      usage
      exit 1
      ;;
    '-l'|'--log-level' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      log_level $2 || exit $?
      shift 2
      ;;
    '--'|'-' )
      shift 1
      param+=( "$@" )
      break
      ;;
    -*)
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
      ;;
    *)
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        if [ -z "$ki_cmd" ]; then
          cmd_chk $1 || exit $?
          ki_cmd=$1
        elif [ -z "$ki_instance" ]; then
          ki_instance=$1
        fi
        #param+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

case "$ki_cmd" in
  'create' )
    func_create $ki_instance $ki_param

    ;;
  'converge' )
    instances=($(instance_list ${ki_instance}))
    for instance in ${instances[@]}
    do
      func_converge $instance $ki_param || exit $?
    done

    ;;
  'setup' )
    instances=($(instance_list ${ki_instance}))
    for instance in ${instances[@]}
    do
      json_data=$(kitchen diagnose ${instance} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)")

      last_action=$(echo ${json_data} | jq -r ".instances.\"${instance}\".state_file.last_action")
      if [ "${last_action}" == "null" -o "${last_action}" == "create" ] ; then
        func_converge $instance $@ || exit $?

        kitchen setup ${ki_instance} $ki_param || exit $?
      fi
    done

    ;;
  'verify' )
    instances=($(instance_list ${ki_instance}))
    for instance in ${instances[@]}
    do
      json_data=$(kitchen diagnose ${instance} | ruby -e "require 'yaml'; require 'json'; puts JSON.pretty_generate YAML.load($<.read)")

      last_action=$(echo ${json_data} | jq -r ".instances.\"${instance}\".state_file.last_action")
      if [ "${last_action}" == "null" -o "${last_action}" == "create" ] ; then
        func_converge $instance $@ || exit $?

        kitchen verify ${instance} $ki_param || exit $?
      fi
    done

    ;;
  'destroy' )
    kitchen destroy ${ki_instance} $ki_param

    ;;
  'test' )
    kitchen destroy ${ki_instance} $ki_param || exit$?

    instances=($(instance_list ${ki_instance}))
    for instance in ${instances[@]}
    do
      func_converge $instance $ki_param || exit $?

      kitchen verify ${instance} $ki_param || exit $?

      kitchen destroy ${instance} $ki_param || exit $?
    done

    ;;
  'list' )
    kitchen list ${ki_instance} $ki_param || exit $?
    ;;
  *)
    usage
    exit 1
    ;;
esac
