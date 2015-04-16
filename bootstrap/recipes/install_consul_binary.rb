include_recipe 'ark::default'

install_arch = node['kernel']['machine'] =~ /x86_64/ ? 'amd64' : '386'
install_version = [node['consul']['version'], node['os'], install_arch].join('_')
install_checksum = node['consul']['checksums'].fetch(install_version)

ark 'consul' do
  path node['consul']['install_dir']
  version node['consul']['version']
  checksum install_checksum
  url node['consul']['base_url'] % { version: install_version }
  action :dump
end

file File.join(node['consul']['install_dir'], 'consul') do
  mode '0755'
  action :touch
end
