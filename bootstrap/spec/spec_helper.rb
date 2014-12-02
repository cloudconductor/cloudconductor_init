require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  root_dir = File.expand_path('./tmp') 
  config.cookbook_path = File.join(root_dir, 'cookbooks')
  config.role_path = File.join(root_dir, 'roles')
  config.log_level = :warn
  config.platform = 'centos'
  config.version = '6.5'
  puts config.cookbook_path
end
