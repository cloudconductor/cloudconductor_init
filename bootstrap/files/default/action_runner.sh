#!/bin/sh

source /opt/cloudconductor/lib/common.sh
source /opt/cloudconductor/lib/python-env.sh

LOG_FILE="${LOG_DIR}/event-handler.log"

script_dir=$(cd $(dirname $0) && pwd)

root_dir=/opt/cloudconductor
patterns_dir=${root_dir}/patterns

logger() {
  level=$1
  message=$2

}

pre_configure() {
  cd ${root_dir}/bin
  /bin/sh ./configure.sh
  status=$?
  if [ ${status} -ne 0 ] ; then
    log_error "pre-configure failed. configure.sh returns ${status}"
    exit ${status}
  fi

  log_info 'pre-configure executed successfully.'
}

send_event() {
  pattern_dir=$1
  role=$2
  event=$3

  pattern_name=${pattern_dir##*/}

  cd $pattern_dir
  /bin/sh ./event_handler.sh $role $event
  status=$?
  if [ ${status} -ne 0 ] ; then
    log_error "${event} event failed on ${pattern_name}. returns ${status}"
    exit ${status}
  fi

  log_info "${event} event executed on ${pattern_name} successfully."
}

role=$1
event=$2

if [ "$event" == "configure" ] ; then
  pre_configure
  sleep 30
fi

patterns=(`python_exec ${script_dir}/patterns.py ${patterns_dir} | jq -r 'sort_by(.metadata.type != "platform") | .[] | .path'`)
status=$?
if [ ${status} -ne 0 ]; then
  exit ${status}
fi

for pattern_dir in ${patterns[@]}
do
  send_event $pattern_dir $role $event
done
