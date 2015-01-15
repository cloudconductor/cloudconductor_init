# override yum-epel attributes
default['yum']['epel']['enabled'] = false

# set cloudconductor parameters related to consul
default['cloudconductor']['consul']['ssl_strength'] = 2048
default['cloudconductor']['consul']['ssl_serial'] = 1
default['cloudconductor']['consul']['ssl_days'] = 3650
default['cloudconductor']['consul']['ssl_subj'] = "/C=JP/ST=cloudconductor/L=cloudconductor/CN=#{`hostname`}.consul"
default['cloudconductor']['consul']['ssl_cert'] = '/etc/pki/tls/certs/consul.crt'
default['cloudconductor']['consul']['ssl_key'] = '/etc/pki/tls/private/consul.key'

# override consul attributes
default['consul']['version'] = '0.4.1'
default['consul']['service_mode'] = 'server'
default['consul']['service_user'] = 'root'
default['consul']['service_group'] = 'root'
default['consul']['bind_addr'] = '0.0.0.0'
default['consul']['ports'] = node['consul']['ports'].merge({'https' => 8501})
default['consul']['datacenter'] = 'dc1'
default['consul']['extra_params'] = {
  'ca_file' => '/etc/pki/tls/cert.pem',
  'cert_file' => node['cloudconductor']['consul']['ssl_cert'],
  'key_file' => node['cloudconductor']['consul']['ssl_key']
}

unless "#{ENV['CONSUL_SECURITY_KEY']}".empty? then
  default['consul']['encrypt'] = ENV['CONSUL_SECURITY_KEY']
  default['consul']['extra_params'].merge!(
    {
      'acl_datacenter' => node['consul']['datacenter'],
      'acl_default_policy' => 'deny',
      'acl_master_token' => ENV['CONSUL_SECURITY_KEY'],
      'acl_token' => 'nothing'
    }
  )
end

# set pattern attributes
default['cloudconductor']['pattern_name'] = ENV['PATTERN_NAME']
default['cloudconductor']['pattern_url'] = ENV['PATTERN_URL']
default['cloudconductor']['pattern_revision'] = ENV['PATTERN_REVISION']

# set eventhandler attributes
default['cloudconductor']['events'] = %w(setup configure deploy backup restore spec)
default['cloudconductor']['event_handlers_dir'] = '/opt/consul/event_handlers'
default['cloudconductor']['role'] = ENV['ROLE']
