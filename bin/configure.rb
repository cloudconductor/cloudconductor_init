# -*- coding: utf-8 -*-
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

require 'fileutils'
require 'logger'
require 'active_support'
require '/opt/cloudconductor/lib/cloud_conductor/consul_util'
require '/opt/cloudconductor/lib/cloud_conductor/serf_util'

class PreConfigureRunner
  def initialize
    FileUtils.mkdir_p(CloudConductor::PatternUtil::LOG_DIR) unless Dir.exist?(CloudConductor::PatternUtil::LOG_DIR)
    log_file = File.join(CloudConductor::PatternUtil::LOG_DIR, 'bootstrap.log')
    @logger = Logger.new(log_file)
  end

  def add_server
    hostname, host_info = CloudConductor::SerfUtil.host_info
    begin
      CloudConductor::ConsulUtil.update_servers(hostname, host_info)
      @logger.info("updated servers successfully.: #{host_info}")
    rescue => exception
      @logger.error("failed to put the host_info to Consul KVS. #{exception.message}")
      raise
    end
  end
end

PreConfigureRunner.new.add_server
