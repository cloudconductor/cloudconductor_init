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
source /opt/cloudconductor/lib/python-env.sh

CONFIG_DIR="${ROOT_DIR}/etc"
LOG_FILE="${LOG_DIR}/bootstrap.log"

log_info "update consul ACL for service synchronization."
enable_service_acl

cd ${CONFIG_DIR}
log_info "execute berks."
#berks vendor ${TMP_DIR}/cookbooks
if [ $? -eq 0 ]; then
  log_info "berks has finished successfully."
else
  log_warn "berks has finished abnormally."
fi

log_info "execute configure.rb."
#ruby ${BIN_DIR}/configure.rb
python_exec ${ROOT_DIR}/bootstrap/lib/regist_server.py
if [ $? -eq 0 ]; then
  log_info "configure.rb has finished successfully."
else
  log_error "configure.rb has finished abnormally."
  exit -1
fi

cd ${ROOT_DIR}
log_info "execute chef-solo."
#chef-solo -j ${CONFIG_DIR}/node_configure.json -c ${CONFIG_DIR}/solo.rb
/bin/sh ${ROOT_DIR}/bootstrap/bin/configure.sh
chefsolo_result=$?
if [ ${chefsolo_result} -eq 0 ]; then
  log_info "chef-solo has finished successfully."
else
  log_error "chef-solo has finished abnormally."
  exit -1
fi
