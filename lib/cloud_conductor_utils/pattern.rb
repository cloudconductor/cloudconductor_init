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
require 'rest-client'
require 'json'
require 'base64'
require 'logger'
require 'yaml'

module CloudConductorUtils
  class Pattern
    ROOT_DIR = '/opt/cloudconductor'
    PATTERNS_ROOT_DIR = File.join(ROOT_DIR, 'patterns')
    TMP_DIR = File.join(ROOT_DIR, 'tmp')
    LOG_DIR = File.join(ROOT_DIR, 'logs')
    BIN_DIR = File.join(ROOT_DIR, 'bin')
    FILECACHE_DIR = File.join(TMP_DIR, 'cache')

    def self.pattern_logger(pattern_name, filename_prefix)
      FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
      log_filename = File.join(LOG_DIR, "#{pattern_name}_#{filename_prefix}")
      logger = Logger.new(log_filename)
      logger.formatter = proc do |severity, datetime, _progname, message|
        "[#{datetime.strftime('%Y-%m-%dT%H:%M:%S')}] #{severity}: #{message}\n"
      end
      logger
    end

    def self.platform_pattern_name
      platform_pattern_dir = ''
      Dir.glob("#{PATTERNS_ROOT_DIR}/*/").each do |pattern_dir|
        metadata_file = File.join(pattern_dir, 'metadata.yml')
        next unless File.exist?(metadata_file) && YAML.load_file(metadata_file)['type'] == 'platform'
        platform_pattern_dir = pattern_dir
        break
      end
      platform_pattern_dir.slice(%r{#{PATTERNS_ROOT_DIR}/(?<pattern_name>[^/]*)}, 'pattern_name')
    end
  end
end
