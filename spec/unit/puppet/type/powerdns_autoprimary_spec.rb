# frozen_string_literal: true

require 'puppet'
require 'puppet/type/powerdns_autoprimary'

describe Puppet::Type.type(:powerdns_autoprimary) do
  let!(:autoprimary) { Puppet::Type.type(:powerdns_autoprimary).new(name: '1.2.3.4@ns1.example.com') }

  it 'has its name set' do
    expect(autoprimary[:name]).to eq('1.2.3.4@ns1.example.com')
  end

  it 'has set account to empty string' do
    expect(autoprimary[:account]).to eq('')
  end
end
