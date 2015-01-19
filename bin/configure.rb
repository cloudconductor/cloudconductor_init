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
require_relative '../lib/cloud_conductor_utils/pattern'

class PreConfigureRunner
  def self.add_server
    init_logger
    hostname, host_info_hash = host_info
    begin
      CloudConductorUtils::Consul.update_servers(hostname, host_info_hash)
      @@logger.info("updated servers successfully.: #{host_info_hash}")
    rescue => exception
      @@logger.error("failed to put the host_info to Consul KVS. #{exception.message}")
      raise
    end
  end

  def self.init_logger
    log_dir = '/opt/cloudconductor/logs'
    FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
    log_file = File.join(log_dir, 'bootstrap.log')
    @@logger = Logger.new(log_file)
  end

  def self.host_info
    hostname = `hostname`.strip
    config_lines = File.open('/opt/cloudconductor/config').read.split("\n")
    config_items = config_lines.map do |config_line|
      config_line.split('=')
    end
    config = Hash[*(config_items.flatten)]

    consul_members_result = `consul members | egrep "^#{hostname} +"`.strip.split(' ')
    ip_address = consul_members_result[1].split(':')[0]
    roles = config['ROLE'].split(',')
    host_info_hash = {
      roles: roles,
      pattern: CloudConductorUtils::Pattern.platform_pattern_name,
      private_ip: ip_address
    }
    [hostname, host_info_hash]
  end
  private_class_method :init_logger, :host_info
end

PreConfigureRunner.add_server if __FILE__ == $PROGRAM_NAME
