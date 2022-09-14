require 'puppet/parameter/boolean'

Puppet::Type.newtype(:powerdns_zone) do
  @doc = 'ensure a zone exists. The zone is managed using the
         resource powerdns_zone_private'

  newparam(:name, namevar: true) do
    desc 'name of the zone name as namevar'

    validate do |value|
      raise ArgumentError, 'The name of the zone needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:zone_ensure) do
    desc 'ensure parameter for the zone, use present/absent'
    defaultto 'present'
  end

  newparam(:config_name) do
    desc "Virtual configuration name for pdnsutil --config-name parameter, defaults to '' which will ignore the parameter."
    defaultto ''

    validate do |value|
      raise ArgumentError, 'config_name needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:config_dir) do
    desc "Location directory of pdns.conf file for pdnsutil --config-dir parameter, defaults to '' which will ignore and take the system default."
    defaultto ''
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:show_diff, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Whether to display differences when the zone changes, defaulting to
        false. Since zones can be huge, use this only for debugging"
    defaultto :false
  end

  newparam(:manage_records, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'If puppet shall manage all zone records for the domain (any records not managed with puppet will be purged).
         The default is true, to manage the SOA record and all zone records through puppet for the zone.
         If set to false, ensurance of zone creation is done only and the administration of zone records needs to be done through
         web Interface or any other preferred method.
         '
    defaultto :true
  end

  newparam(:soa_ttl) do
    desc 'ttl for SOA record'
    defaultto '3600'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_class) do
    desc 'zone class for SOA record'
    defaultto 'IN'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_mname) do
    desc 'primary master name server for the zone for SOA record'
    defaultto 'a.powerdns.server'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_rname) do
    desc 'Email address of the administrator responsible for this zone for SOA record'
    defaultto 'hostmaster'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_refresh) do
    desc 'Number of seconds after which secondary name servers should query the master for the SOA record, to detect zone changes'
    defaultto '10800'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_retry) do
    desc 'Number of seconds after which secondary name servers should retry to request the serial number from the master if the master does not respond'
    defaultto '3600'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_expire) do
    desc 'Number of seconds after which secondary name servers should stop answering request for this zone if the master does not respond.'
    defaultto '604800'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  newparam(:soa_minttl) do
    desc 'Minimum ttl in seconds, negativ response caching ttl'
    defaultto '3600'
    validate do |value|
      raise ArgumentError, 'config_dir needs to be a string' unless value.is_a?(String)
    end
  end

  def soa_record
    # create the soa record
    soa = [self['soa_mname'], self['soa_rname'], '_SERIAL_', self['soa_refresh'], self['soa_retry'], self['soa_expire'], self['soa_minttl']].join(' ')
    [self['name'], self['soa_ttl'], self['soa_class'], 'SOA', soa].join("\t")
  end

  def records
    # Collect records that target this zone.
    @records ||= catalog.resources.map { |resource|
      next unless resource.is_a?(Puppet::Type.type(:powerdns_record))

      resource if resource[:target_zone] == title
    }.compact
  end

  def should_content
    # collect and sort all records for content
    content = [].push(soa_record)

    records.each do |r|
      if r[:rname] == '.'
        content.push([r[:target_zone], r[:rttl], r[:rclass], r[:rtype], r[:rcontent]].join("\t"))
      else
        content.push([r[:rname] + '.' + r[:target_zone], r[:rttl], r[:rclass], r[:rtype], r[:rcontent]].join("\t"))
      end
      # rubocop:enable Style/StringConcatenation
    end
    content.push("$ORIGIN .\n") # add this, since it's always in the output..
    content.sort.join("\n")
  end
  # rubocop:enable Metrics/AbcSize

  def generate
    # create the powerdns_zone_private resource as a copy of this resource
    # without content
    powerdns_zone_private_opts = {}

    [:name,
     :config_name,
     :config_dir,
     :show_diff,
     :manage_records].each do |p|
      powerdns_zone_private_opts[p] = self[p] unless self[p].nil?
    end
    powerdns_zone_private_opts['ensure'] = self['zone_ensure']

    excluded_metaparams = [:before, :notify, :require, :subscribe, :tag]

    Puppet::Type.metaparams.each do |metaparam|
      powerdns_zone_private_opts[metaparam] = self[metaparam] unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
    end

    [Puppet::Type.type(:powerdns_zone_private).new(powerdns_zone_private_opts)]
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def eval_generate
    # add the content to the powerdns_zone_private resource containing
    # ower on content and the content of the matching powerdns_record resources
    content = should_content
    catalog.resource("Powerdns_zone_private[#{self[:name]}]")[:content] = content

    [catalog.resource("Powerdns_zone_private[#{self[:name]}]")]
  end

  # autorequire the powerdns class
  autorequire(:service) do
    ['pdns']
  end

  # autorequire the powerdns_records
  autorequire(:powerdns_record) do
  end
  # rubocop:enable Lint/EmptyBlock
end
