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
require_relative '../../../lib/cloud_conductor_utils/pattern'

module CloudConductorUtils
  describe Pattern do
    describe '#pattern_logger' do
      it 'creates and returns the logger instance' do
        allow(Dir).to receive(:exist?).with('/opt/cloudconductor/logs').and_return(true)
        allow(FileUtils).to receive(:mkdir_p).with('/opt/cloudconductor/logs')
        dummy_logger = Object.new
        double('Logger', new: dummy_logger)
        allow(dummy_logger).to receive(:formatter=)
        allow(Logger).to receive(:new).with(
          '/opt/cloudconductor/logs/testpattern_testlog.log'
        ).and_return(dummy_logger)
        logger = Pattern.pattern_logger('testpattern', 'testlog.log')
        expect(logger).not_to be_nil
      end
    end

    describe '#platform_pattern_name' do
      it 'extracts the name of platform pattern' do
        dummy_dirs = %w(
          /opt/cloudconductor/patterns/pattern1
          /opt/cloudconductor/patterns/pattern2
          /opt/cloudconductor/patterns/pattern3
        )
        allow(Dir).to receive(:glob).with('/opt/cloudconductor/patterns/*/').and_return(dummy_dirs)
        allow(File).to receive(:exist?).and_return(true)
        allow(YAML).to receive(:load_file).with(
          '/opt/cloudconductor/patterns/pattern1/metadata.yml'
        ).and_return('type' => 'optional')
        allow(YAML).to receive(:load_file).with(
          '/opt/cloudconductor/patterns/pattern2/metadata.yml'
        ).and_return('type' => 'platform')
        allow(YAML).to receive(:load_file).with(
          '/opt/cloudconductor/patterns/pattern3/metadata.yml'
        ).and_return('type' => 'test')
        platform_pattern_name = Pattern.platform_pattern_name
        expect(platform_pattern_name).to eq('pattern2')
      end
    end
  end
end
