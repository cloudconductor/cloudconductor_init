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

source /opt/cloudconductor/lib/common.sh

CONFIG_DIR="${ROOT_DIR}/etc"
LOG_FILE="${LOG_DIR}/bootstrap.log"

cd ${ROOT_DIR}
log_info "execute bundler."
bundle install --without test development
if [ $? -eq 0 ]; then
  log_info "bundler has finished successfully."
else
  log_error "bundler has finished abnormally."
  exit -1
fi

cd ${TMP_DIR}
log_info "install cloud_conductor_utils."
git clone https://github.com/cloudconductor/cloud_conductor_utils.git
cd cloud_conductor_utils
git checkout develop
rake build
cd pkg
gem install ./*.gem

cd ${CONFIG_DIR}
log_info "execute berks."
berks vendor ${TMP_DIR}/cookbooks
if [ $? -eq 0 ]; then
  log_info "berks has finished successfully."
else
  log_warn "berks has finished abnormally."
fi

cd ${ROOT_DIR}
log_info "execute chef-solo."
chef-solo -j ${CONFIG_DIR}/node_setup.json -c ${CONFIG_DIR}/solo.rb
chefsolo_result=$?
if [ ${chefsolo_result} -eq 0 ]; then
  log_info "chef-solo has finished successfully."
else
  log_error "chef-solo has finished abnormally."
  exit -1
fi

log_info "execute event-handler with setup event."
SERF_USER_EVENT="setup" /opt/serf/event_handlers/event-handler
if [ $? -eq 0 ]; then
  log_info "event-handler has finished successfully."
else
  log_error "event-handler has finished abnormally."
  exit -1
fi
