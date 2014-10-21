event_handlers_path = File.join(node['serf']['base_directory'], 'event_handlers')

# override yum-epel attributes
default['yum']['epel']['enabled'] = false

# override serf attributes
default['serf']['version'] = '0.6.3'
default['serf']['agent']['bind'] = '0.0.0.0'
default['serf']['agent']['rpc_addr'] = '0.0.0.0:7373'
default['serf']['agent']['enable_syslog'] = true
default['serf']['agent']['event_handlers'] = [
  File.join(event_handlers_path, 'event-handler'),
  "query:chef_status=#{File.join(event_handlers_path, 'check_chef_status.sh')}"
]
default['serf']['agent']['tags']['role'] = ENV['SERF_TAG_ROLE']
default['serf']['user'] = 'root'
default['serf']['group'] = 'root'

# override consul attributes
default['consul']['service_mode'] = 'server'
default['consul']['service_user'] = 'root'
default['consul']['service_group'] = 'root'
default['consul']['bind_addr'] = '0.0.0.0'

# set pattern attributes
default['cloudconductor']['pattern_name'] = ENV['PATTERN_NAME']
default['cloudconductor']['pattern_url'] = ENV['PATTERN_URL']
default['cloudconductor']['pattern_revision'] = ENV['PATTERN_REVISION']
