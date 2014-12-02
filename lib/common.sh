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

export ROOT_DIR="/opt/cloudconductor"
export LOG_DIR="${ROOT_DIR}/logs"
export TMP_DIR="${ROOT_DIR}/tmp"
export BIN_DIR="${ROOT_DIR}/bin"
export FILECACHE_DIR="${TMP_DIR}/cache"
export CHEF_ENV_FILE="/etc/profile.d/chef.sh"

function chefdk_path() {
  echo "`cat ${CHEF_ENV_FILE} | awk -F: '{print $2}'`"
}

function log() {
  level="$1"
  message="$2"
  echo "[`date +'%Y-%m-%dT%H:%M:%S'`] ${level}: ${message}" >> ${LOG_FILE}
}

function log_debug() {
  message="$1"
  log "DEBUG" "${message}"
}

function log_info() {
  message="$1"
  log "INFO" "${message}"
}

function log_warn() {
  message="$1"
  log "WARN" "${message}"
}

function log_error() {
  message="$1"
  log "ERROR" "${message}"
}

function log_fatal() {
  message="$1"
  log "FATAL" "${message}"
}

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
    result="null"
  else
    result="\"$3\""
  fi
  if [ "$4" == "null" ]; then
    start_datetime="null"
  else
    start_datetime="\"$4\""
  fi
  if [ "$5" == "null" ]; then
    end_datetime="null"
  else
    end_datetime="\"$5\""
  fi
  data="{\"event_id\":${event_id},\"type\":${type},\"result\":${result},\"start_datetime\":${start_datetime},\"end_datetime\":${end_datetime}}"
  curl -X PUT http://localhost:8500/v1/kv/event/${event_id_key}/`hostname` -d "${data}" >/dev/null 2>&1
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
