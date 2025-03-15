# frozen_string_literal: true

require 'puppet'
require 'puppet/type/powerdns_zone'

describe Puppet::Type.type(:powerdns_zone) do
  let!(:zone) { Puppet::Type.type(:powerdns_zone).new(name: 'example.com') }

  it 'has its name set' do
    expect(zone[:name]).to eq('example.com')
  end

  it 'has set config_dir to empty string' do
    expect(zone[:config_dir]).to eq('')
  end

  it 'has set config_name to empty string' do
    expect(zone[:config_name]).to eq('')
  end
end
