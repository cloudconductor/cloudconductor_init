# -*- coding: utf-8 -*-
require 'json'
require 'rest-client'
require 'base64'
require 'logger'

class Chef::Recipe::BootstrapHelper < Chef::Recipe

  ROOT_DIR = '/opt/cloudconductor'
  LOG_DIR = File.join(ROOT_DIR, 'tmp/logs')
  LOG_FILE = File.join(LOG_DIR, 'bootstrap_helper.log')
  CONSUL_KVS_PARAMETERS_URL = 'http://127.0.0.1:8500/v1/kv/cloudconductor/parameters'

  def initialize(chef_recipe)
    super(chef_recipe.cookbook_name, chef_recipe.recipe_name, chef_recipe.run_context)
    @logger = Logger.new(LOG_FILE)
  end

  def getOptionalPatterns
    parameters = read_parameters
    patterns = parameters[:cloudconductor][:patterns]
    result = []
    patterns.each do |pattern_name, pattern|
      pattern[:pattern_name] = pattern_name
      result << pattern if pattern[:type] == 'optional'
    end
    result
  end

  private

  def read_parameters
    parameters = {}
    begin
      response = RestClient.get(CONSUL_KVS_PARAMETERS_URL)
      response_hash = JSON.parse(response, symbolize_names: true).first
      parameters_json = Base64.decode64(response_hash[:Value])
      parameters = JSON.parse(parameters_json, symbolize_names: true)
      @logger.info("read parameters successfully.: #{parameters}")
    rescue => exception
      @logger.warn("failed to get the parameters[#{url}] from Consul KVS. #{exception.message}")
    end
    parameters
  end
end
