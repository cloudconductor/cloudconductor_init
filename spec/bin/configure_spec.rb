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
require_relative '../../bin/configure.rb'

describe PreConfigureRunner do
  describe 'initialize' do
    it 'creates and returns new instance' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      dummy_logger = Object.new
      allow(Logger).to receive(:new).with('/opt/cloudconductor/logs/bootstrap.log').and_return(dummy_logger)
      pre_configure_runner = PreConfigureRunner.new
      def pre_configure_runner.logger
        @logger
      end
      expect(pre_configure_runner.logger).to eq(dummy_logger)
    end
  end

  describe 'add_server' do
    it 'call Consul#update_servers' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      dummy_logger = Object.new
      allow(Logger).to receive(:new).with('/opt/cloudconductor/logs/bootstrap.log').and_return(dummy_logger)
      allow(CloudConductorUtils::Serf).to receive(:host_info).and_return(['testhost', {key: 'value'}])
      allow(CloudConductorUtils::Consul).to receive(:update_servers).with('testhost', {key: 'value'})
      def dummy_logger.info(_message)
      end
      PreConfigureRunner.new.add_server
    end
  end
end
