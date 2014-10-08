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

# checkout pattern
pattern_name = ENV['PATTERN_NAME']
pattern_url = ENV['PATTERN_URL']
pattern_revision = ENV['PATTERN_REVISION']
git "/opt/cloudconductor/patterns/#{pattern_name}" do
  repository "#{pattern_url}"
  revision "#{pattern_revision}"
  action :checkout
end

# setup consul services information of the pattern
Dir["/opt/cloudconductor/patterns/#{pattern_name}/services/**/*"].each do |service_file|
  file "/etc/consul.d/#{Pathname.new(service_file).basename}" do
    content IO.read(service_file)
  end if File.file?(service_file)
end
