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
require 'yaml'
require '/opt/cloudconductor/lib/cloud_conductor/pattern_util'

class ActionRunner
  BIN_DIR = File.join(CloudConductor::PatternUtil::ROOT_DIR, 'bin')
  LOG_FILE = File.join(CloudConductor::PatternUtil::LOG_DIR, 'event-handler.log')
  VALID_EVENT = %w(setup configure deploy backup restore spec)

  def initialize
    FileUtils.mkdir_p(CloudConductor::PatternUtil::LOG_DIR) unless Dir.exist?(CloudConductor::PatternUtil::LOG_DIR)
    @logger = Logger.new(LOG_FILE)
    @logger.formatter = proc do |severity, datetime, _progname, message|
      "[#{datetime.strftime('%Y-%m-%dT%H:%M:%S')}] #{severity}: #{message}\n"
    end
    @serf_user_event = ENV['SERF_USER_EVENT']
    @serf_tag_role = ENV['SERF_TAG_ROLE']
  end

  def execute
    if VALID_EVENT.include?(@serf_user_event)
      execute_pre_configure
      execute_pattern('platform')
      execute_pattern('optional')
    else
      @logger.info("event [#{@serf_user_event}] is ignored.")
    end
  end

  private

  def execute_pre_configure
    return unless @serf_user_event == 'configure'
    @logger.info('execute pre-configure.')
    pre_configure_result = system("cd #{BIN_DIR}; ./configure.sh")
    if pre_configure_result
      @logger.info('pre-configure executed successfully.')
    else
      fail
    end
  end

  def execute_pattern(type)
    Dir.glob("#{CloudConductor::PatternUtil::PATTERNS_ROOT_DIR}/*/").each do |pattern_dir|
      metadata_file = File.join(pattern_dir, 'metadata.yml')
      next unless File.exist?(metadata_file) && YAML.load_file(metadata_file)['type'] == type
      @logger.info("execute pattern [#{pattern_dir}]")
      result = system("cd #{pattern_dir}; ./execute_pattern.sh #{@serf_tag_role} #{@serf_user_event}")
      if result
        @logger.info('executed successfully.')
      else
        fail
      end
    end
  end
end

ActionRunner.new.execute
