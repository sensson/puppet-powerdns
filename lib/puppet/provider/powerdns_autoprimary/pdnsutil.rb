# frozen_string_literal: true

Puppet::Type.type(:powerdns_autoprimary).provide(:pdnsutil) do
  desc "@summary provider which provides autprimary,
        using the pdnsutil command."

  commands pdnsutil: 'pdnsutil'

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.instances
    pdnsutil('list-autoprimaries').split("\n").map do |line|
      raise Puppet::Error, "Cannot parse invalid autoprimary line: #{line}" unless line =~ %r{^IP=(\S+),\s+NS=(\S+),\s+account=(\S*)$}

      new(
        ensure: :present,
        name: "#{Regexp.last_match(1)}@#{Regexp.last_match(2)}",
        account: Regexp.last_match(3)
      )
    end
  end

  def self.prefetch(resources)
    autoprimaries = instances
    resources.each_key do |name|
      if (provider = autoprimaries.find { |aprim| aprim.name == name })
        resources[name].provider = provider
      end
    end
  end

  def create
    pdnsutil('add-autoprimary', resource[:name].split('@'), resource[:account])
    @property_hash[:ensure] = :present
  end

  def destroy
    pdnsutil('remove-autoprimary', resource[:name].split('@'))
    @property_hash[:ensure] = :absent
  end

  def account
    @property_hash[:account]
  end

  def account=(account)
    pdnsutil('remove-autoprimary', resource[:name].split('@'))
    pdnsutil('add-autoprimary', resource[:name].split('@'), account)
    @property_hash[:ensure] = account
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def flush
    return if @property_flush.empty?

    content = @property_flush[:content] || @resource[:content]
    virsh_define(content)
    @property_flush.clear
  end
end
