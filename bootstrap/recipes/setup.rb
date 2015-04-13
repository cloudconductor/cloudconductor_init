include_recipe 'yum-epel'
include_recipe 'iptables::disabled'

pattern_name = node['cloudconductor']['pattern_name']
event_handlers_dir = node['cloudconductor']['event_handlers_dir']

# create directory for Consul event-handler
directory event_handlers_dir do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :create
end

# install event-handler
cookbook_file File.join(event_handlers_dir, 'event-handler') do
  source 'event-handler'
  mode 0755
end

cookbook_file File.join(event_handlers_dir, 'action_runner.rb') do
  source 'action_runner.rb'
  mode 0755
end

# create self-signed certificate for Consul HTTPS API
consul_ssl_strength = node['cloudconductor']['consul']['ssl_strength']
consul_ssl_serial = node['cloudconductor']['consul']['ssl_serial']
consul_ssl_days = node['cloudconductor']['consul']['ssl_days']
consul_ssl_subj = node['cloudconductor']['consul']['ssl_subj']
consul_ssl_cert = node['cloudconductor']['consul']['ssl_cert']
consul_ssl_key = node['cloudconductor']['consul']['ssl_key']
bash 'create_self_signed_cerficiate' do
  code <<-EOH
    openssl req -new -newkey rsa:#{consul_ssl_strength} -sha1 -x509 -nodes \
      -set_serial #{consul_ssl_serial} \
      -days #{consul_ssl_days} \
      -subj "#{consul_ssl_subj}" \
      -out "#{consul_ssl_cert}" \
      -keyout "#{consul_ssl_key}"
  EOH
end

include_recipe 'bootstrap::install_consul_binary'
include_recipe 'consul::_service'

# override Consul service template
r = resources(template: '/etc/init.d/consul')
r.cookbook 'bootstrap'

# install Consul watches configuration file
watches = []
node['cloudconductor']['events'].each do |event|
  watch = {
    'type' => 'event',
    'name' => event,
    'handler' => "#{File.join(event_handlers_dir, 'event-handler')} #{event}"
  }
  watches << watch
end
watches_configuration = {
  'watches' => watches
}
template File.join(node['consul']['config_dir'], 'watches.json') do
  source 'watches.json.erb'
  mode 0755
  variables(
    watches_configuration: watches_configuration
  )
end

# delete 70-persistent-net.rules extra lines
ruby_block 'delete 70-persistent-net.rules extra line' do
  block do
    file = Chef::Util::FileEdit.new('/etc/udev/rules.d/70-persistent-net.rules')
    file.search_file_replace_line('^SUBSYSTEM.*', '')
    file.search_file_replace_line('^# PCI device .*', '')
    file.write_file
  end
  only_if { File.exist?('/etc/udev/rules.d/70-persistent-net.rules') }
end

# delete consul data
ruby_block 'delete consul data' do
  block do
    require 'fileutils'
    FileUtils.rm_rf(Dir.glob(File.join(node['consul']['data_dir'], '*')))
  end
  action :nothing
end

# checkout pattern
git "/opt/cloudconductor/patterns/#{pattern_name}" do
  repository "#{node['cloudconductor']['pattern_url']}"
  revision "#{node['cloudconductor']['pattern_revision']}"
  action :checkout
end

# create symbolic link to pattern logs
link "/opt/cloudconductor/logs/#{pattern_name}" do
  to "/opt/cloudconductor/patterns/#{pattern_name}/logs"
end

# setup consul services information of the pattern
ruby_block 'install service' do
  block do
    roles = node['cloudconductor']['role'].split(',')
    roles << 'all'
    roles.each do |role|
      Dir["/opt/cloudconductor/patterns/#{pattern_name}/services/#{role}/**/*"].each do |service_file|
        FileUtils.cp(service_file, "/etc/consul.d/#{Pathname.new(service_file).basename}")
      end
    end
  end
  notifies :stop, 'service[consul]', :delayed
  notifies :run, 'ruby_block[delete consul data]', :delayed
end

# install jq
package 'jq' do
  action :install
  options '--enablerepo=epel'
end

# install serverspec
gem_package 'serverspec' do
  action :install
end

# install hping3
package 'hping3' do
  action :install
  options '--enablerepo=epel'
end
