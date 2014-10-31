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

if [ ! -d ${LOG_DIR} ]; then
  mkdir -p ${LOG_DIR}
fi

if [ ! -d ${TMP_DIR} ]; then
  mkdir -p ${TMP_DIR}
fi

if [ ! -d ${FILECACHE_DIR} ]; then
  mkdir -p ${FILECACHE_DIR}
fi
