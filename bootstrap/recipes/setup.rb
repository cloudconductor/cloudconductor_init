include_recipe 'iptables::disabled'
include_recipe 'serf'

# override template
r = resources(template: '/etc/init.d/serf')
r.cookbook 'bootstrap'

# install event-handler
serf_helper = SerfHelper.new self
template node['serf']['agent']['event_handlers'].first do
  source 'event-handler.erb'
  mode 0755
  variables event_handlers_directory: serf_helper.getEventHandlersDirectory
end

cookbook_file "#{serf_helper.getEventHandlersDirectory}/action_runner.rb" do
  source 'action_runner.rb'
  mode 0755
end

include_recipe 'consul::install_binary'
include_recipe 'consul::_service'

# override Consul service template
r = resources(template: '/etc/init.d/consul')
r.cookbook 'bootstrap'

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

# stop Consul and delete its data at the end forcely by notification
ruby_block 'stop consul' do
  block do
  end
  notifies :stop, 'service[consul]', :delayed
  notifies :run, 'ruby_block[delete consul data]', :delayed
end

# checkout platform pattern
platform_pattern_name = ENV['PLATFORM_PATTERN_NAME']
platform_pattern_url = ENV['PLATFORM_PATTERN_URL']
platform_pattern_revision = ENV['PLATFORM_PATTERN_REVISION']
git "/opt/cloudconductor/patterns/#{platform_pattern_name}" do
  repository "#{platform_pattern_url}"
  revision "#{platform_pattern_revision}"
  action :checkout
end

# TODO: setup consul services information of platform pattern
# Dir[ "/opt/cloudconductor/patterns/#{platform_pattern_name}/services/**/*" ].each do |service_file|
#   file "#{node['consul']['config_dir']}/#{Pathname.new(service_file).basename}" do
#     content { IO.read(service_file).read }
#     action :create
#   end if File.file?(service_file)
# end
