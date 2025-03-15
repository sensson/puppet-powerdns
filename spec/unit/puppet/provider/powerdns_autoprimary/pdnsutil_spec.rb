# frozen_string_literal: true

require 'spec_helper'

provider_class = Puppet::Type.type(:powerdns_autoprimary).provider(:pdnsutil)

describe provider_class do
  let(:resource) do
    Puppet::Type::Powerdns_autoprimary.new(
      name: '1.2.3.4@ns1.example.com',
      provider: described_class.name
    )
  end

  let(:provider) { provider_class.new(resource) }

  it 'has its name set' do
    expect(resource[:name]).to eq('1.2.3.4@ns1.example.com')
  end
end
