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
require_relative '../lib/consul/consul_util'
require_relative '../lib/serf/serf_util'

class PreConfigureRunner
  ROOT_DIR = '/opt/cloudconductor'
  LOG_DIR = File.join(ROOT_DIR, 'tmp/logs')
  LOG_FILE = File.join(LOG_DIR, 'pre_configure_runner.log')

  def initialize
    FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
    @logger = Logger.new(LOG_FILE)
  end

  def add_server
    hostname, host_info = Serf::SerfUtil.host_info
    begin
      Consul::ConsulUtil.update_servers(hostname, host_info)
      @logger.info("updated servers successfully.: #{host_info}")
    rescue => exception
      @logger.error("failed to put the host_info to Consul KVS. #{exception.message}")
    end
  end
end

PreConfigureRunner.new.add_server
