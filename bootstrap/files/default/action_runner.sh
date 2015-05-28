#!/bin/sh -e
# Copyright 2014-2015 TIS Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
