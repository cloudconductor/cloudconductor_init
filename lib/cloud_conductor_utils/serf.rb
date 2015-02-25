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
require_relative './pattern'

module CloudConductorUtils
  class Serf
    def self.host_info
      hostname = `hostname`.strip
      serf_members_result = `serf members -name="^#{hostname}$"`.strip.split(' ')
      ip_address = serf_members_result[1].split(':')[0]
      roles = serf_members_result[3].split('=')[1].split(',')
      host_info = {
        roles: roles,
        pattern: CloudConductorUtils::Pattern.platform_pattern_name,
        private_ip: ip_address
      }
      [hostname, host_info]
    end
  end
end