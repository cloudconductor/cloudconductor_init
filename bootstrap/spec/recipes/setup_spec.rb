require_relative '../spec_helper'

describe 'bootstrap::setup' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      cookbook_path: ['../../../tmp/cookbooks'],
      platform:      'centos',
      version:       '6.5'
    ).converge('bootstrap::setup')
  end

  before do
    ENV['PATTERN_NAME'] = 'test_pattern'
    ENV['PATTERN_URL'] = 'test_url'
    ENV['PATTERN_REVISION'] = 'test_revision'
    ENV['SERF_TAG_ROLE'] = 'web,ap,db'
  end

  it 'install yum-epel' do
    expect(chef_run).to include_recipe('yum-epel')
  end

  it 'iptables disabled' do
    expect(chef_run).to include_recipe('iptables::disabled')
  end

  it 'install serf' do
    expect(chef_run).to include_recipe('serf')
  end

  it 'override serf service template' do
    r = chef_run.find_resource(:template, '/etc/init.d/serf')
    expect(r.cookbook).to eq('bootstrap')
  end

  it 'install event-handler' do
    expect(chef_run).to create_template('/opt/serf/event_handlers/event-handler').with(
      source: 'event-handler.erb',
      mode: 0755,
      variables: {event_handlers_directory: '/opt/serf/event_handlers'}
    )
  end

  it 'install action_runner.rb' do
    expect(chef_run).to create_cookbook_file('/opt/serf/event_handlers/action_runner.rb').with(
      source: 'action_runner.rb',
      mode: 0755
    )
  end

  it 'install consul' do
    expect(chef_run).to include_recipe('consul::install_binary')
  end

  it 'install consul service' do
    expect(chef_run).to include_recipe('consul::_service')
  end

  it 'override Consul service template' do
    r = chef_run.find_resource(:template, '/etc/init.d/consul')
    expect(r.cookbook).to eq('bootstrap')
  end

  it 'delete 70-persistent-net.rules extra lines' do
    allow(File).to receive(:exist?).and_return(true)
    expect(chef_run).to run_ruby_block('delete 70-persistent-net.rules extra line')
  end

  it 'delete consul data' do
    expect(chef_run).to_not run_ruby_block('delete consul data')
  end

  it 'stop Consul and delete its data at the end forcely by notification' do
    r = chef_run.find_resource(:ruby_block, 'stop consul')
    expect(r).to notify('service[consul]').to(:stop).delayed
    expect(r).to notify('ruby_block[delete consul data]').to(:run).delayed
  end

  it 'checkout pattern' do
    expect(chef_run).to checkout_git('/opt/cloudconductor/patterns/test_pattern').with(
      repository: 'test_url',
      revision: 'test_revision',
    )
  end

  it 'create symbolic link to pattern logs' do
    expect(chef_run).to create_link('/opt/cloudconductor/logs/test_pattern').with(
      to: '/opt/cloudconductor/patterns/test_pattern/logs'
    )
  end

  it 'setup consul services information of the pattern' do
    # TODO: implement test
  end

  it 'install serverspec' do
    expect(chef_run).to install_gem_package('serverspec').with(
      version: '1.16.0'
    )
  end

  it 'install hping3' do
    expect(chef_run).to install_package('hping3').with(
      options: '--enablerepo=epel'
    )
  end
end
