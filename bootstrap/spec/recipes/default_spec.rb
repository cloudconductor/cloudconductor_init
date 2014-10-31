require_relative '../spec_helper'

describe 'bootstrap::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      cookbook_path: ['../../../tmp/cookbooks'],
      platform:      'centos',
      version:       '6.5'
    ).converge('bootstrap::default')
  end

  before do
    ENV['PATTERN_NAME'] = 'test_pattern'
    ENV['PATTERN_URL'] = 'test_url'
    ENV['PATTERN_REVISION'] = 'test_revision'
    ENV['SERF_TAG_ROLE'] = 'web,ap,db'
  end

  it 'include setup' do
    expect(chef_run).to include_recipe('bootstrap::setup')
  end
end
