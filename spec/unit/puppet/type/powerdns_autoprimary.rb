require 'puppet'
require 'puppet/type/powerdns_autoprimary'

describe Puppet::Type.type(:powerdns_autoprimary) do
  let!(:zone) { Puppet::Type.type(:powerdns_autoprimary).new(name: '1.2.3.4@ns1.example.com') }

  it 'has its name set' do
    expect(zone[:name]).to eq('1.2.3.4@ns1.example.com')
  end
  it 'has set config_dir to empty string' do
    expect(zone[:config_dir]).to eq('')
  end
  it 'has set config_name to empty string' do
    expect(zone[:config_name]).to eq('')
  end
end
