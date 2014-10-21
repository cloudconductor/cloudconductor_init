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
require 'cloud_conductor_utils/consul'
require_relative '../lib/cloud_conductor_utils/serf'

class PreConfigureRunner
  def initialize
    log_dir = '/opt/cloudconductor/logs'
    FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
    log_file = File.join(log_dir, 'bootstrap.log')
    @logger = Logger.new(log_file)
  end

  def add_server
    hostname, host_info = CloudConductorUtils::Serf.host_info
    begin
      CloudConductorUtils::Consul.update_servers(hostname, host_info)
      @logger.info("updated servers successfully.: #{host_info}")
    rescue => exception
      @logger.error("failed to put the host_info to Consul KVS. #{exception.message}")
      raise
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  PreConfigureRunner.new.add_server
end
