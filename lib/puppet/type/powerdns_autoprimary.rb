# frozen_string_literal: true

require 'puppet/parameter/boolean'

Puppet::Type.newtype(:powerdns_autoprimary) do
  @doc = 'ensures autoprimary servers (for automatic provisioning of secondaries)
         '

  ensurable do
    desc 'Manage the state of this type.'
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'name of the autoprimary in the format IP@NAMESERVER'

    newvalues(%r{^\S+@\S+$})
  end

  newproperty(:account) do
    desc 'account to ensure (default to no account)'
    defaultto ''

    validate do |value|
      raise ArgumentError, 'ip needs to be a string' unless value.is_a?(String)
    end
  end

  autorequire(:service) do
    ['pdns']
  end
end
