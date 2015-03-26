require_relative '../spec_helper'
require 'chefspec'

describe 'bootstrap::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("/usr/local/go/bin/go version | grep \"go1.3 \"").and_return(true)
    ENV['PATTERN_NAME'] = 'test_pattern'
    ENV['PATTERN_URL'] = 'test_url'
    ENV['PATTERN_REVISION'] = 'test_revision'
    ENV['ROLE'] = 'web,ap,db'
  end

  it 'install yum-epel' do
    expect(chef_run).to include_recipe('yum-epel')
  end

  it 'iptables disabled' do
    expect(chef_run).to include_recipe('iptables::disabled')
  end

  it 'create event_handler_dir' do
    expect(chef_run).to create_directory('/opt/consul/event_handlers').with(
      owner: 'root',
      group: 'root',
      mode: 0755
    )
  end

  it 'install event-handler' do
    expect(chef_run).to create_cookbook_file('/opt/consul/event_handlers/event-handler').with(
      source: 'event-handler',
      mode: 0755
    )
  end

  it 'install action_runner.rb' do
    expect(chef_run).to create_cookbook_file('/opt/consul/event_handlers/action_runner.rb').with(
      source: 'action_runner.rb',
      mode: 0755
    )
  end

  it 'install consul' do
    expect(chef_run).to include_recipe('consul::install_source')
  end

  it 'install consul service' do
    expect(chef_run).to include_recipe('consul::_service')
  end

  it 'override Consul service template' do
    r = chef_run.find_resource(:template, '/etc/init.d/consul')
    expect(r.cookbook).to eq('bootstrap')
  end

  it 'install Consul watches configuration file' do
    expect(chef_run).to create_template('/etc/consul.d/watches.json').with(
      source: 'watches.json.erb',
      mode: 0755
    )
  end

  it 'delete 70-persistent-net.rules extra lines' do
    allow(File).to receive(:exist?).and_return(true)
    expect(chef_run).to run_ruby_block('delete 70-persistent-net.rules extra line')
  end

  it 'delete consul data' do
    expect(chef_run).to_not run_ruby_block('delete consul data')
  end

  it 'checkout pattern' do
    expect(chef_run).to checkout_git('/opt/cloudconductor/patterns/test_pattern').with(
      repository: 'test_url',
      revision: 'test_revision'
    )
  end

  it 'create symbolic link to pattern logs' do
    expect(chef_run).to create_link('/opt/cloudconductor/logs/test_pattern').with(
      to: '/opt/cloudconductor/patterns/test_pattern/logs'
    )
  end

  it 'setup consul services information of the pattern' do
    expect(chef_run).to run_ruby_block('install service')
    r = chef_run.find_resource(:ruby_block, 'install service')
    expect(r).to notify('service[consul]').to(:stop).delayed
    expect(r).to notify('ruby_block[delete consul data]').to(:run).delayed
  end

  it 'inslall jq' do
    expect(chef_run).to install_package('jq')
  end

  it 'install serverspec' do
    expect(chef_run).to install_gem_package('serverspec')
  end

  it 'install hping3' do
    expect(chef_run).to install_package('hping3').with(
      options: '--enablerepo=epel'
    )
  end
end
