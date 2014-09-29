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
    CONSUL_KVS_URL = 'http://127.0.0.1:8500/v1/kv/cloudconductor'
    CONSUL_KVS_PARAMETERS_URL = "#{CONSUL_KVS_URL}/parameters"
    CONSUL_KVS_SERVERS_URL = "#{CONSUL_KVS_URL}/servers"

    def self.read_parameters
      begin
        response = RestClient.get(CONSUL_KVS_PARAMETERS_URL)
        response_hash = JSON.parse(response, symbolize_names: true).first
        parameters_json = Base64.decode64(response_hash[:Value])
        parameters = JSON.parse(parameters_json, symbolize_names: true)
      rescue
        parameters = {}
      end
      parameters
    end

    def self.update_parameters(parameters)
      RestClient.put(CONSUL_KVS_PARAMETERS_URL, parameters.to_json)
    end

    def self.read_servers
      begin
        servers = {}
        response = RestClient.get("#{CONSUL_KVS_SERVERS_URL}?recurse")
        JSON.parse(response, symbolize_names: true).each do |response_hash|
          key = response_hash[:Key]
          next if key == 'cloudconductor/servers'
          hostname = key.slice(%r{cloudconductor/servers/(?<hostname>[^/]*)}, 'hostname')
          server_info_json = Base64.decode64(response_hash[:Value])
          servers[hostname] = JSON.parse(server_info_json, symbolize_names: true)
        end
      rescue
        servers = {}
      end
      servers
    end

    def self.update_servers(hostname, server_info)
      RestClient.put("#{CONSUL_KVS_SERVERS_URL}/#{hostname}", server_info.to_json)
    end
  end
end
