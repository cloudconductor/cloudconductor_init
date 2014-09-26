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

require '/opt/cloudconductor/lib/consul/consul_util'

class BootstrapHelper < Chef::Recipe
  def initialize(chef_recipe)
    super(chef_recipe.cookbook_name, chef_recipe.recipe_name, chef_recipe.run_context)
  end

  def optional_patterns
    parameters = Consul::ConsulUtil.read_parameters
    patterns = parameters[:cloudconductor][:patterns]
    result = []
    patterns.each do |pattern_name, pattern|
      pattern[:pattern_name] = pattern_name
      result << pattern if pattern[:type] == 'optional'
    end
    result
  end
end
