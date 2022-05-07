# frozen_string_literal: true

require 'spec_helper'

provider_class = Puppet::Type.type(:powerdns_zone_private).provider(:pdnsutil)

describe provider_class do
  let(:resource) do
    Puppet::Type::Powerdns_zone_private.new(
      name: 'example.com',
      provider: described_class.name
    )
  end

  let(:provider) { provider_class.new(resource) }
end
