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
    def dummy_logger.formatter=(prc)
      @prc = prc
    end
    def dummy_logger.formatter
      @prc
    end
    def dummy_logger.info(message)
      @message = message
    end
    def dummy_logger.warn(message)
      @message = message
    end
    def dummy_logger.error(message)
      @message = message
    end
    allow(Logger).to receive(:new).with(
      '/opt/cloudconductor/logs/testpattern_testlog.log'
    ).and_return(dummy_logger)
    allow(Logger).to receive(:new).with(
      '/opt/cloudconductor/logs/event-handler.log'
    ).and_return(dummy_logger)
  end

  describe '#initialize' do
    it 'creates and returns new instance' do
      ENV['SERF_USER_EVENT'] = 'setup'
      ENV['SERF_TAG_ROLE'] = 'web,ap,db'
      action_runner = ActionRunner.new
      def action_runner.logger
        @logger
      end
      def action_runner.serf_user_event
        @serf_user_event
      end
      def action_runner.serf_tag_role
        @serf_tag_role
      end
      expect(action_runner.logger).not_to be_nil
      expect(action_runner.serf_user_event).to eq('setup')
      expect(action_runner.serf_tag_role).to eq('web,ap,db')
    end
  end

  describe '#execute' do
    it 'skips when event is invalid' do
      ENV['SERF_USER_EVENT'] = 'test'
      ENV['SERF_TAG_ROLE'] = 'web,ap,db'
      action_runner = ActionRunner.new
      action_runner.execute
      expect(ActionRunner).not_to receive(:execute_pre_configure)
      expect(ActionRunner).not_to receive(:execute_pattern)
    end

    it 'applies patterns' do
      ENV['SERF_USER_EVENT'] = 'setup'
      ENV['SERF_TAG_ROLE'] = 'web,ap,db'
      allow(ActionRunner).to receive(:execute_pre_configure)
      allow(ActionRunner).to receive(:execute_pattern).with('platform')
      allow(ActionRunner).to receive(:execute_pattern).with('optional')
      action_runner = ActionRunner.new
      action_runner.execute
    end
  end

  describe '#execute_pre_configure' do
    it 'skips when serf_event is not configure' do
      ENV['SERF_USER_EVENT'] = 'setup'
      ENV['SERF_TAG_ROLE'] = 'web,ap,db'
      action_runner = ActionRunner.new
      def action_runner.system(command)
        @command = command
        true
      end
      action_runner.send(:execute_pre_configure)
      expect(action_runner).not_to receive(:system)
    end

    it 'runs execute_pre_configure' do
      ENV['SERF_USER_EVENT'] = 'configure'
      ENV['SERF_TAG_ROLE'] = 'web,ap,db'
      action_runner = ActionRunner.new
      def action_runner.system(command)
        @command = command
        true
      end
      def action_runner.command
        @command
      end
      action_runner.send(:execute_pre_configure)
      expect(action_runner.command).to eq('cd /opt/cloudconductor/bin; ./configure.sh')
    end
  end

  describe '#execute_pattern' do
    it 'executes target patterns' do
      ENV['SERF_USER_EVENT'] = 'setup'
      ENV['SERF_TAG_ROLE'] = 'web,ap,db'
      dummy_patterns = %w(/tmp/pattern1 /tmp/pattern2 /tmp/pattern3)
      allow(Dir).to receive(:glob).with('/opt/cloudconductor/patterns/*/').and_return(dummy_patterns)
      allow(File).to receive(:exist?).and_return(true)
      allow(YAML).to receive(:load_file).with('/tmp/pattern1/metadata.yml').and_return('type' => 'platform')
      allow(YAML).to receive(:load_file).with('/tmp/pattern2/metadata.yml').and_return('type' => 'optional')
      allow(YAML).to receive(:load_file).with('/tmp/pattern3/metadata.yml').and_return('type' => 'optional')
      action_runner = ActionRunner.new
      def action_runner.system(command)
        @command = [] if @command.nil?
        @command << command
        true
      end
      def action_runner.command
        @command
      end
      action_runner.send(:execute_pattern, 'optional')
      expected_strings = [
        'cd /tmp/pattern2; ./event_handler.sh web,ap,db setup',
        'cd /tmp/pattern3; ./event_handler.sh web,ap,db setup'
      ]
      expect(action_runner.command).to eq(expected_strings)
    end
  end
end
