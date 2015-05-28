#! /bin/sh -e
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
source /opt/cloudconductor/lib/run-base.sh

LOG_FILE="${LOG_DIR}/bootstrap.log"

run which chef-solo
if [ $status -ne 0 ]; then
  log_info "install chef."
  curl -L http://www.opscode.com/chef/install.sh | bash
fi

run which ruby
if [ $status -ne 0 ]; then
  if [[ -d /opt/chefdk ]] && [[ -x /opt/chefdk/embedded/bin/ruby ]]; then
    ruby_home=/opt/chefdk/embedded
    log_info "set chefdk_path."
  elif [[ -d /opt/chef ]] && [[ -x /opt/chef/embedded/bin/ruby ]]; then
    ruby_home=/opt/chef/embedded
    log_info "set chef_path."
  fi

  echo "export PATH=\$PATH:${ruby_home}/bin" > ${CHEF_ENV_FILE}
  export PATH=${ruby_home}/bin:${PATH}
fi

run bash -c "gem list | grep berkshelf"
if [ $status -ne 0 ]; then
  yum install -y make gcc gcc-c++ autoconf
  gem install berkshelf
fi

cd ${TMP_DIR}
log_info "install cloud_conductor_utils."
git clone https://github.com/cloudconductor/cloud_conductor_utils.git

cd cloud_conductor_utils
rake build

cd pkg
run gem install ./*.gem
if [ $status -ne 0 ]; then
  log_error "install cloud_conductor_utils has finished abnormally."
  log_error "${output}"
  echo "${output}" >&2
  exit $status
fi

log_info "install cloud_conductor_utils has finished successfully."

run gem install serverspec
if [ $status -ne 0 ]; then
  log_error "install serverspec has finished abnormally."
  log_error "${output}"
  exit $status
fi
log_info "install serverspec has finished successfully."
