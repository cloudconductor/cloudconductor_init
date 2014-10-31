require_relative '../spec_helper'

describe 'bootstrap::configure' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      cookbook_path: ['../../../tmp/cookbooks'],
      platform:      'centos',
      version:       '6.5'
    ).converge('bootstrap::configure')
  end

  it 'checkout optional patterns, and setup consul services information of optional patterns' do
    # TODO: implement test
  end

  it 'reload consul' do
    expect(chef_run).to reload_service('consul')
  end
end
