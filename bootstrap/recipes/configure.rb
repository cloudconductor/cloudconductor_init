::Chef::Recipe.send(:include, CloudConductor::BootstrapHelper)

# checkout optional patterns, and setup consul services information of optional patterns
optional_patterns.each do |pattern|
  git "/opt/cloudconductor/patterns/#{pattern[:pattern_name]}" do
    repository "#{pattern[:url]}"
    revision "#{pattern[:revision]}"
    action :checkout
  end

  link "/opt/cloudconductor/logs/#{pattern[:pattern_name]}" do
    to "/opt/cloudconductor/patterns/#{pattern[:pattern_name]}/logs"
  end

  ruby_block "install #{pattern[:pattern_name]} services" do
    block do
      Dir["/opt/cloudconductor/patterns/#{pattern[:pattern_name]}/services/all/**/*"].each do |service_file|
        FileUtils.cp(service_file, "/etc/consul.d/#{Pathname.new(service_file).basename}")
      end
    end
  end
end

# reload consul
service 'consul' do
  action :reload
  supports [:reload]
end
