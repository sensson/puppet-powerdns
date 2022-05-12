Puppet::Type.newtype(:powerdns_record) do
  @doc = ' ensure a zone exists.'

  newparam(:name, namevar: true) do
    desc 'name of the record as namevar'

    validate do |value|
      raise ArgumentError, 'The name of the zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:target_zone) do
    desc 'the target zone defaults to all characters after the first . in the title.'
    defaultto { @resource[:name].split('.').drop(1).join('.') }

    validate do |value|
      raise ArgumentError, 'target_zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:rname) do
    desc "the name of the record to add (remark target zone will be added)
          defaults to the first characters of the title until the first '.'.
          to add a record equal the taget_zone, add a '.' only.
         "
    defaultto { @resource[:name].split('.')[0] }
    validate do |value|
      raise ArgumentError, 'target_zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:rclass) do
    desc "the class of record (defaults to 'IN')"
    defaultto 'IN'
    validate do |value|
      raise ArgumentError, 'target_zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:rtype) do
    desc 'the record type'
    defaultto 'A'
    validate do |value|
      raise ArgumentError, 'target_zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:rttl) do
    desc 'the ttl of the record'
    defaultto '3600'
    validate do |value|
      raise ArgumentError, 'target_zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:rcontent) do
    desc 'the content of the record'
  end
end
