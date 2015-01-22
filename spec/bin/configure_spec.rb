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
  describe '#initialize' do
    it 'creates and returns new instance' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      dummy_logger = Object.new
      allow(Logger).to receive(:new).with('/opt/cloudconductor/logs/bootstrap.log').and_return(dummy_logger)
      pre_configure_runner = PreConfigureRunner.new
      expect(pre_configure_runner.instance_variable_get(:@logger)).to eq(dummy_logger)
    end
  end

  describe '#add_server' do
    it 'calls Consul#update_servers' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      dummy_logger = Object.new
      allow(Logger).to receive(:new).with('/opt/cloudconductor/logs/bootstrap.log').and_return(dummy_logger)
      allow(CloudConductorUtils::Consul).to receive(:update_servers).with('testhost', key: 'value')
      allow(dummy_logger).to receive(:info)
      pre_configure_runner = PreConfigureRunner.new
      allow(pre_configure_runner).to receive(:host_info).and_return(
        [
          'testhost',
          {
            key: 'value'
          }
        ]
      )
      pre_configure_runner.add_server
    end
  end

  describe '#host_info' do
    it 'returns host information' do
      allow(Dir).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:mkdir_p)
      dummy_logger = Object.new
      allow(Logger).to receive(:new).with('/opt/cloudconductor/logs/bootstrap.log').and_return(dummy_logger)
      allow(File).to receive_message_chain(:open, :read).and_return(
        "ROLE=web,ap,db\n" \
        'KEY=value'
      )
      pre_configure_runner = PreConfigureRunner.new
      allow(pre_configure_runner).to receive(:`).with('hostname').and_return('testhost')
      allow(pre_configure_runner).to receive(:`).with('consul members | egrep "^testhost +"').and_return(
        'testhost      127.0.0.1:8301   alive   server  0.4.1  2'
      )
      allow(CloudConductorUtils::Pattern).to receive(:platform_pattern_name).and_return('test_pattern')
      host_info = pre_configure_runner.send(:host_info)
      expected_value = [
        'testhost',
        {
          roles: %w(web ap db),
          pattern: 'test_pattern',
          private_ip: '127.0.0.1'
        }
      ]
      expect(host_info).to eq(expected_value)
    end
  end
end
