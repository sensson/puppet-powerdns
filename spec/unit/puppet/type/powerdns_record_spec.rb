require 'puppet'
require 'puppet/type/powerdns_record'

describe Puppet::Type.type(:powerdns_record) do
  before(:each) do
    @res = Puppet::Type.type(:powerdns_record).new(name: 'www.example.com')
  end

  it 'has its name set' do
    expect(@res[:name]).to eq('www.example.com')
  end
  it 'has set target zone' do
    expect(@res[:target_zone]).to eq('example.com')
  end
  it 'has set rname' do
    expect(@res[:rname]).to eq('www')
  end
end
