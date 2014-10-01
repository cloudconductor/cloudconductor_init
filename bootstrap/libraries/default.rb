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

require '/opt/cloudconductor/lib/cloud_conductor/consul_util'

module CloudConductor
  module BootstrapHelper
    def optional_patterns
      result = []
      parameters = CloudConductor::ConsulUtil.read_parameters
      return result if parameters[:cloudconductor].nil? || parameters[:cloudconductor][:patterns].nil?
      patterns = parameters[:cloudconductor][:patterns]
      patterns.each do |pattern_name, pattern|
        pattern[:pattern_name] = pattern_name
        result << pattern if pattern[:type] == 'optional'
      end
      result
    end
  end
end
