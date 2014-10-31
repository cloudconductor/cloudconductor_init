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

  Dir["/opt/cloudconductor/patterns/#{pattern[:pattern_name]}/services/**/*"].each do |service_file|
    file "/etc/consul.d/#{Pathname.new(service_file).basename}" do
      content IO.read(service_file)
    end if File.file?(service_file)
  end
end

# reload consul
service 'consul' do
  action :reload
end
