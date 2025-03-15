# frozen_string_literal: true

require 'puppet'
require 'puppet/type/powerdns_record'

describe Puppet::Type.type(:powerdns_record) do
  let!(:dns_record) { Puppet::Type.type(:powerdns_record).new(name: 'www.example.com') }

  it 'has its name set' do
    expect(dns_record[:name]).to eq('www.example.com')
  end

  it 'has set target zone' do
    expect(dns_record[:target_zone]).to eq('example.com')
  end

  it 'has set rname' do
    expect(dns_record[:rname]).to eq('www')
  end
end
