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
require_relative '../../../../bootstrap/files/default/action_runner.rb'

describe ActionRunner do
  before do
    allow(Dir).to receive(:exist?).and_return(true)
    allow(FileUtils).to receive(:mkdir_p)
    dummy_logger = Object.new
    double('Logger', new: dummy_logger)
    allow(dummy_logger).to receive(:formatter=)
    allow(Logger).to receive(:new).with(
      '/opt/cloudconductor/logs/testpattern_testlog.log'
    ).and_return(dummy_logger)
    allow(Logger).to receive(:new).with(
      '/opt/cloudconductor/logs/event-handler.log'
    ).and_return(dummy_logger)
    allow(dummy_logger).to receive(:debug)
    allow(dummy_logger).to receive(:info)
    allow(dummy_logger).to receive(:warn)
    allow(dummy_logger).to receive(:error)
  end

  describe '#initialize' do
    it 'creates and returns new instance' do
      event = 'setup'
      role = 'web,ap,db'
      action_runner = ActionRunner.new(role, event)
      expect(action_runner.instance_variable_get(:@logger)).not_to be_nil
      expect(action_runner.instance_variable_get(:@event)).to eq('setup')
      expect(action_runner.instance_variable_get(:@role)).to eq('web,ap,db')
    end
  end

  describe '#execute' do
    it 'skips when event is invalid' do
      event = 'test'
      role = 'web,ap,db'
      action_runner = ActionRunner.new(role, event)
      action_runner.execute
      expect(ActionRunner).not_to receive(:execute_pre_configure)
      expect(ActionRunner).not_to receive(:execute_pattern)
    end

    it 'applies patterns' do
      event = 'setup'
      role = 'web,ap,db'
      allow(ActionRunner).to receive(:execute_pre_configure)
      allow(ActionRunner).to receive(:execute_pattern).with('platform')
      allow(ActionRunner).to receive(:execute_pattern).with('optional')
      action_runner = ActionRunner.new(role, event)
      action_runner.execute
    end
  end

  describe '#execute_pre_configure' do
    it 'skips when serf_event is not configure' do
      event = 'setup'
      role = 'web,ap,db'
      action_runner = ActionRunner.new(role, event)
      allow(action_runner).to receive(:system).and_return(0)
      action_runner.send(:execute_pre_configure)
      expect(action_runner).not_to receive(:system)
    end

    it 'runs execute_pre_configure' do
      event = 'configure'
      role = 'web,ap,db'
      action_runner = ActionRunner.new(role, event)
      allow(action_runner).to receive(:system).with('cd /opt/cloudconductor/bin; /bin/sh ./configure.sh').and_return(0)
      action_runner.send(:execute_pre_configure)
    end
  end

  describe '#execute_pattern' do
    it 'executes target patterns' do
      event = 'setup'
      role = 'web,ap,db'
      dummy_patterns = %w(/tmp/pattern1 /tmp/pattern2 /tmp/pattern3)
      allow(Dir).to receive(:glob).with('/opt/cloudconductor/patterns/*/').and_return(dummy_patterns)
      allow(File).to receive(:exist?).and_return(true)
      allow(YAML).to receive(:load_file).with('/tmp/pattern1/metadata.yml').and_return('type' => 'platform')
      allow(YAML).to receive(:load_file).with('/tmp/pattern2/metadata.yml').and_return('type' => 'optional')
      allow(YAML).to receive(:load_file).with('/tmp/pattern3/metadata.yml').and_return('type' => 'optional')
      action_runner = ActionRunner.new(role, event)
      allow(action_runner).to receive(:system).with('cd /tmp/pattern2; /bin/sh ./event_handler.sh web,ap,db setup').and_return(0)
      allow(action_runner).to receive(:system).with('cd /tmp/pattern3; /bin/sh ./event_handler.sh web,ap,db setup').and_return(0)
      action_runner.send(:execute_pattern, 'optional')
    end
  end
end
