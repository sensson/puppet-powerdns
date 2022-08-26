# This file contains a provider for the resource type `powerdns_zone`,
#
require 'tempfile'
Puppet::Type.type(:powerdns_zone_private).provide(
  :pdnsutil,
) do
  desc "A provider for the resource type `powerdns_zone`,
        which manages a zone on powerdns
        using the pdnsutil command."

  commands pdnsutil: 'pdnsutil'

  def pdnsutil_options
    options = []
    if resource[:config_name].to_s != ''
      options.insert(0, '--config-name')
      options.insert(1, resource[:config_name])
    end
    if resource[:config_dir].to_s != ''
      options.insert(0, '--config-dir')
      options.insert(1, resource[:config_dir])
    end
    options
  end

  def create
    pdnsutil pdnsutil_options, 'create-zone', resource[:name]
    pdnsutil_set_records('1') if resource[:manage_records]
  end

  def destroy
    pdnsutil pdnsutil_options, 'delete-zone', resource[:name]
  end

  def content=(_content)
    return unless resource[:manage_records]

    pdnsutil_set_records(@serial)
    pdnsutil pdnsutil_options, 'increase-serial', resource[:name]
  end

  def pdnsutil_set_records(serial)
    tmpfile = Tempfile.new(resource[:name])
    tmpfile.write(resource[:content].gsub(%r{_SERIAL_}, serial))
    tmpfile.rewind
    pdnsutil(pdnsutil_options, 'load-zone', resource[:name], tmpfile.path)
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  def find_soa(records)
    records.each_with_index do |r, idx|
      return idx if r.include?('SOA')
    end
    'notfound'
  end

  def content
    return '' unless resource[:manage_records]

    c = pdnsutil(pdnsutil_options, 'list-zone', resource[:name])
    records = c.split("\n")
    soanr = find_soa(records)
    if soanr == 'notfound'
      @serial = '1'
      return c
    end
    soarec = records[soanr].split(' ')
    @serial = soarec[-5]
    soarec[-5] = '_SERIAL_'
    records[soanr] = soarec[0..3].join("\t") + "\t" + soarec[4..10].join(' ')
    records.sort.join("\n") + "\n" end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def exists?
    pdnsutil(pdnsutil_options, 'list-all-zones').split("\n").each do |line|
      return true if line == resource[:name]
    end
    false
  end
end
