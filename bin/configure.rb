# -*- coding: utf-8 -*-

require 'fileutils'
require 'json'
require 'logger'
require 'rest-client'
require 'base64'
require 'active_support'
require 'yaml'

class PreConfigureRunner
  ROOT_DIR = '/opt/cloudconductor'
  LOG_DIR = File.join(ROOT_DIR, 'tmp/logs')
  LOG_FILE = File.join(LOG_DIR, 'pre_configure_runner.log')
  CONSUL_KVS_PARAMETERS_URL = "http://127.0.0.1:8500/v1/kv/cloudconductor/parameters"
  PATTERNS_ROOT_DIR = File.join(ROOT_DIR, 'patterns')

  def initialize
    FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
    @logger = Logger.new(LOG_FILE)
  end

  def add_server
    parameters = {}
    begin
      response = RestClient.get(CONSUL_KVS_PARAMETERS_URL)
      response_hash = JSON.parse(response, symbolize_names: true).first
      parameters_json = Base64.decode64(response_hash[:Value])
      parameters = JSON.parse(parameters_json, symbolize_names: true)
      @logger.info("read parameters successfully.: #{parameters}")
    rescue => exception
      @logger.warn("failed to get the parameters from Consul KVS. #{exception.message}")
    end
    hostname, host_info = get_host_info
    new_server = {
      cloudconductor: {
        servers: {
          hostname => host_info          
        }
      }
    }
    parameters.deep_merge!(new_server)
    begin
      RestClient.put(CONSUL_KVS_PARAMETERS_URL, parameters.to_json)
      @logger.info("updated parameters successfully.: #{parameters}")
    rescue => exception
      @logger.warn("failed to put the parameters to Consul KVS. #{exception.message}")
    end
  end

  private
  
  def get_host_info
    hostname = `hostname`.strip
    serf_members_result = `serf members -name="^#{hostname}$"`.strip.split(' ')
    ip_address = serf_members_result[1].split(':')[0]
    roles = serf_members_result[3].split('=')[1].split(',')
    host_info = {
      roles: roles,
      pattern: get_platform_pattern_name,
      private_ip: ip_address
    }
    [hostname, host_info]
  end

  def get_platform_pattern_name
    platform_pattern_dir = ''
    Dir.glob("#{PATTERNS_ROOT_DIR}/*/").each do |pattern_dir|
      metadata_file = File.join(pattern_dir, 'metadata.yml')
      next unless File.exist?(metadata_file) and YAML.load_file(metadata_file)['type'] == 'platform'
      platform_pattern_dir = pattern_dir
      break
    end
    platform_pattern_dir.slice(%r{#{PATTERNS_ROOT_DIR}/(?<pattern_name>[^/]*)}, 'pattern_name')
  end
end

PreConfigureRunner.new().add_server
