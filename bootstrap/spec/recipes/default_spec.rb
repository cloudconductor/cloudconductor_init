require_relative '../spec_helper'
require 'chefspec'

describe 'bootstrap::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("/usr/local/go/bin/go version | grep \"go1.3 \"").and_return(true)
    ENV['PATTERN_NAME'] = 'test_pattern'
    ENV['PATTERN_URL'] = 'test_url'
    ENV['PATTERN_REVISION'] = 'test_revision'
    ENV['ROLE'] = 'web,ap,db'
  end

  it 'include setup recipe' do
    expect(chef_run).to include_recipe 'bootstrap::setup'
  end
end
