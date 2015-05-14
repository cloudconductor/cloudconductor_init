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

log_info "set chefdk_path."
echo "export PATH=\$PATH:/opt/chefdk/embedded/bin" > ${CHEF_ENV_FILE}
export PATH=`chefdk_path`:${PATH}

cd ${TMP_DIR}
log_info "install cloud_conductor_utils."
git clone https://github.com/cloudconductor/cloud_conductor_utils.git
cd cloud_conductor_utils
rake build
cd pkg
gem install ./*.gem
if [ $? -eq 0 ]; then
  log_info "install cloud_conductor_utils has finished successfully."
else
  log_error "install cloud_conductor_utils has finished abnormally."
  exit -1
fi

cd ${CONFIG_DIR}
log_info "execute berks."
berks vendor ${TMP_DIR}/cookbooks
if [ $? -eq 0 ]; then
  log_info "berks has finished successfully."
else
  log_warn "berks has finished abnormally."
fi

cd ${ROOT_DIR}
log_info "execute first setup."
#chef-solo -j ${CONFIG_DIR}/node_setup.json -c ${CONFIG_DIR}/solo.rb
/bin/sh ./bootstrap/bin/setup.sh
chefsolo_result=$?
if [ ${chefsolo_result} -eq 0 ]; then
  log_info "first-setup has finished successfully."
else
  log_error "first-setup has finished abnormally."
  exit -1
fi

log_info "execute event-handler with setup event."
CONSUL_SECRET_KEY_BASE64=`echo "${CONSUL_SECRET_KEY}" | base64`
echo "[{\"ID\":\"0\", \"Payload\":\"${CONSUL_SECRET_KEY_BASE64}\"}]" | /bin/sh /opt/consul/event_handlers/event-handler setup
if [ $? -eq 0 ]; then
  log_info "event-handler has finished successfully."
else
  log_error "event-handler has finished abnormally."
  exit -1
fi
