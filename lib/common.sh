#!/bin/sh
# Copyright 2014 TIS Inc.
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

export HOME=/root
export PATH=/usr/local/bin:${PATH}
export ROOT_DIR="/opt/cloudconductor"
export LOG_DIR="${ROOT_DIR}/logs"
export TMP_DIR="${ROOT_DIR}/tmp"
export BIN_DIR="${ROOT_DIR}/bin"
export FILECACHE_DIR="${TMP_DIR}/cache"
export CHEF_ENV_FILE="/etc/profile.d/chef.sh"
export CONFIG_FILE="${ROOT_DIR}/config"

function chefdk_path() {
  echo "`cat ${CHEF_ENV_FILE} | awk -F: '{print $2}'`"
}

# $1: log level
# $2: log message
function log() {
  level="$1"
  message="$2"
  echo "[`date +'%Y-%m-%dT%H:%M:%S'`] ${level}: ${message}" >> ${LOG_FILE}
}

# called from log() internally
function log_debug() {
  message="$1"
  log "DEBUG" "${message}"
}

# called from log() internally
function log_info() {
  message="$1"
  log "INFO" "${message}"
}

# called from log() internally
function log_warn() {
  message="$1"
  log "WARN" "${message}"
}

# called from log() internally
function log_error() {
  message="$1"
  log "ERROR" "${message}"
}

# called from log() internally
function log_fatal() {
  message="$1"
  log "FATAL" "${message}"
}

# $1: config key
# $2: config value
function write_config_value() {
  touch ${CONFIG_FILE}
  if [ -n "`egrep \"^$1=\" ${CONFIG_FILE}`" ]; then
    sed -ri "s/^$1=.*/$1=\"$2\"/" ${CONFIG_FILE}
  else
    echo "$1=\"$2\"" >> ${CONFIG_FILE}
  fi
}

# $1: config key
function read_config_value() {
  echo "`(. ${CONFIG_FILE}; echo ${!1})`"
}

# $1: event id
# $2: event type (ex. configure, deploy)
# $3: result code
# $4: datetime the event has started at
# $5: datetime tha event has finished at
# &6: running log
function write_event_handler_result() {
  if [ "$1" == "null" ]; then
    event_id="null"
    event_id_key="null"
  else
    event_id="\"$1\""
    event_id_key="$1"
  fi
  if [ "$2" == "null" ]; then
    type="null"
  else
    type="\"$2\""
  fi
  if [ "$3" == "null" ]; then
    return_code="null"
  else
    return_code="\"$3\""
  fi
  if [ "$4" == "null" ]; then
    started_at="null"
  else
    started_at="\"$4\""
  fi
  if [ "$5" == "null" ]; then
    finished_at="null"
  else
    finished_at="\"$5\""
  fi
  if [ "$6" == "null" ]; then
    running_log="null"
  else
    running_log="`echo \"$6\" | ruby -e \"puts STDIN.read.inspect\"`"
  fi
  CONSUL_SECRET_KEY="`read_config_value CONSUL_SECRET_KEY`"
  CONSUL_SECRET_KEY_ENCODED=$(python -c "import urllib; print urllib.quote('${CONSUL_SECRET_KEY}')")
  data="{\"event_id\":${event_id},\"type\":${type},\"return_code\":${return_code},\"started_at\":${started_at},\"finished_at\":${finished_at}}"
  curl -X PUT "http://localhost:8500/v1/kv/event/${event_id_key}/`hostname`?token=${CONSUL_SECRET_KEY_ENCODED}" -d "${data}" >/dev/null 2>&1
  curl -X PUT "http://localhost:8500/v1/kv/event/${event_id_key}/`hostname`/log?token=${CONSUL_SECRET_KEY_ENCODED}" -d "${running_log}" >/dev/null 2>&1
}

function enable_service_acl() {
  CONSUL_SECRET_KEY="`read_config_value CONSUL_SECRET_KEY`"
  CONSUL_SECRET_KEY_ENCODED=$(python -c "import urllib; print urllib.quote('${CONSUL_SECRET_KEY}')")
  curl -X PUT "http://localhost:8500/v1/acl/update?token=${CONSUL_SECRET_KEY_ENCODED}" -d '{"ID": "anonymous", "Name": "anonymous", "Type": "client", "Rules": "key \"/\" {policy = \"deny\"} service \"\" {policy = \"write\"}"}' >/dev/null 2>&1
}

if [ ! -d ${LOG_DIR} ]; then
  mkdir -p ${LOG_DIR}
fi

if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR}
fi

if [ ! -d ${FILECACHE_DIR} ]; then
  mkdir -p ${FILECACHE_DIR}
fi
