require 'puppet'
require 'puppet/type/powerdns_zone'

describe Puppet::Type.type(:powerdns_zone) do
  before(:each) do
    @res = Puppet::Type.type(:powerdns_zone).new(name: 'example.com')
  end

  it 'has its name set' do
    expect(@res[:name]).to eq('example.com')
  end
  it 'has set config_dir to empty string' do
    expect(@res[:config_dir]).to eq('')
  end
  it 'has set config_name to empty string' do
    expect(@res[:config_name]).to eq('')
  end
end
