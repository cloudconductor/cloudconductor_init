require_relative '../spec_helper'

describe 'bootstrap::setup' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      cookbook_path: ['site-cookbooks', 'cookbooks'],
      platform:      'centos',
      version:       '6.5'
    ).converge('bootstrap::setup')
  end

  it 'include setup' do
    expect(chef_run).to include_recipe 'bootstrap::setup'
  end
end
