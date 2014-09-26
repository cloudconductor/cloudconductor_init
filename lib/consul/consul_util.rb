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

module Consul
  class ConsulUtil
    CONSUL_KVS_PARAMETERS_URL = 'http://127.0.0.1:8500/v1/kv/cloudconductor/parameters'

    def self.read_parameters
      begin
        response = RestClient.get(CONSUL_KVS_PARAMETERS_URL)
        response_hash = JSON.parse(response, symbolize_names: true).first
        parameters_json = Base64.decode64(response_hash[:Value])
        parameters = JSON.parse(parameters_json, symbolize_names: true)
      rescue => exception
        parameters = {} 
      end
      parameters
    end

    def self.update_parameters(parameters)
      begin
        RestClient.put(CONSUL_KVS_PARAMETERS_URL, parameters.to_json)
      rescue => exception
        fail
      end
    end
  end
end
