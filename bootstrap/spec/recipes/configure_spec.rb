require_relative '../spec_helper'
require 'chefspec'

describe 'bootstrap::configure' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("/usr/local/go/bin/go version | grep \"go1.3 \"").and_return(true)
    allow_any_instance_of(Chef::Recipe).to receive(:optional_patterns).and_return(
      [
        {
          pattern_name: 'optional1',
          url: 'http://test.com/optional1.git',
          revision: 'develop1'
        },
        {
          pattern_name: 'optional2',
          url: 'http://test.com/optional2.git',
          revision: 'develop2'
        }
      ]
    )
  end

  it 'checkout optional patterns, and setup consul services information of optional patterns' do
    expect(chef_run).to checkout_git('/opt/cloudconductor/patterns/optional1').with(
      repository: 'http://test.com/optional1.git',
      revision: 'develop1'
    )
    expect(chef_run).to create_link('/opt/cloudconductor/logs/optional1').with(
      to: '/opt/cloudconductor/patterns/optional1/logs'
    )
  end

  it 'create symbolic link to pattern log directory' do
    expect(chef_run).to checkout_git('/opt/cloudconductor/patterns/optional2').with(
      repository: 'http://test.com/optional2.git',
      revision: 'develop2'
    )
    expect(chef_run).to create_link('/opt/cloudconductor/logs/optional2').with(
      to: '/opt/cloudconductor/patterns/optional2/logs'
    )
  end

  it 'setup consul services information of the pattern' do
    expect(chef_run).to run_ruby_block('install optional1 services')
    expect(chef_run).to run_ruby_block('install optional2 services')
  end

  it 'reload consul' do
    expect(chef_run).to reload_service('consul')
  end
end
