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
source /opt/cloudconductor/lib/run-base.sh

CONFIG_DIR="${ROOT_DIR}/etc"
LOG_FILE="${LOG_DIR}/bootstrap.log"

cd ${ROOT_DIR}
log_info "execute first-setup."
run ./bootstrap/bin/setup.sh
if [ ${status} -ne 0 ]; then
  log_error "first-setup has finished abnormally."
  log_error ${output}
  echo ${output} >&2
  exit ${status}
fi
log_info "first-setup has finished successfully."

log_info "execute event-handler with setup event."
CONSUL_SECRET_KEY_BASE64=`echo "${CONSUL_SECRET_KEY}" | base64`
echo "[{\"ID\":\"0\", \"Payload\":\"${CONSUL_SECRET_KEY_BASE64}\"}]" | /bin/sh /opt/consul/event_handlers/event-handler setup
if [ $? -eq 0 ]; then
  log_info "event-handler has finished successfully."
else
  log_error "event-handler has finished abnormally."
  exit -1
fi
