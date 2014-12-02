# override yum-epel attributes
default['yum']['epel']['enabled'] = false

# override consul attributes
default['consul']['version'] = '0.4.1'
default['consul']['service_mode'] = 'server'
default['consul']['service_user'] = 'root'
default['consul']['service_group'] = 'root'
default['consul']['bind_addr'] = '0.0.0.0'

# set pattern attributes
default['cloudconductor']['pattern_name'] = ENV['PATTERN_NAME']
default['cloudconductor']['pattern_url'] = ENV['PATTERN_URL']
default['cloudconductor']['pattern_revision'] = ENV['PATTERN_REVISION']

# set eventhandler attributes
default['cloudconductor']['events'] = %w(setup configure deploy backup restore spec)
default['cloudconductor']['event_handlers_dir'] = '/opt/consul/event_handlers'
default['cloudconductor']['role'] = ENV['ROLE']
