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
require_relative '../../../lib/cloud_conductor_utils/serf'

module CloudConductorUtils
  describe Serf do
    describe 'host_info' do
      it 'formats and returns information of host' do
        hostname = 'dummyhost'
        dummy_info = 'dummyhost 192.168.0.1:7946 alive role=web,ap,db'
        allow(CloudConductorUtils::Serf).to receive(:`).with('hostname').and_return(hostname)
        allow(CloudConductorUtils::Serf).to receive(:`).with('serf members -name="^dummyhost$"').and_return(dummy_info)
        allow(CloudConductorUtils::Pattern).to receive(:platform_pattern_name).and_return('platform1')
        expected = [
          'dummyhost',
          {
            roles: %w(web ap db),
            pattern: 'platform1',
            private_ip: '192.168.0.1'
          }
        ]
        result = Serf.host_info
        expect(result.to_s).to eq(expected.to_s)
      end
    end
  end
end
