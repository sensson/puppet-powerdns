# private resource which collected all the records through powerdns_zone
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:powerdns_zone_private) do
  @doc = 'ensure a zone exists. This is a private class do NOT use it in your mannifests instead use powerdns_zone which will
         call this resource with the zone records added.'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'name of the zone name as namevar'

    validate do |value|
      raise ArgumentError, 'The name of the zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:config_name) do
    desc "Virtual configuration name, defaults to '' which will ignore the property."
    defaultto ''

    validate do |value|
      raise ArgumentError, 'config_name needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:config_dir) do
    desc 'Location of pdns.conf. Default is which will ignore the property.'
    defaultto ''
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:manage_records, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'if we manage the all zone records for the domain (any records not managed with puppet will be purged).'
    defaultto :true
  end

  newparam(:show_diff, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Whether to display differences when the zone changes, defaulting to
        false. Since zones can be huge, use this only for debugging"
    defaultto :false
  end

  newproperty(:content) do
    desc "Content (records) of the zone. This must match the output of 'pdnsutil list-zone ZONE|sort'."

    munge do |value|
      if @resource[:manage_records]
        value.to_s.gsub(%r{\n+$}, '') + "\n"
      else
        ''
      end
    end

    def should_to_s(value)
      if @resource[:show_diff]
        ":\n" + value
      else
        '{md5}' + Digest::MD5.hexdigest(value.to_s)
      end
    end

    def is_to_s(value) # rubocop:disable Naming/PredicateName
      if @resource[:show_diff]
        ":\n" + value
      else
        '{md5}' + Digest::MD5.hexdigest(value.to_s)
      end
    end
  end

  # autorequire the powerdns class
  autorequire(:service) do
    ['pdns']
  end
  autorequire(:powerdns_zone) do
  end
  # rubocop:enable Lint/EmptyBlock
end
