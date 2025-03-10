# powerdns::authoritative
#
# @param group
#   Name of the group associated with the pdns authoritative service - needed to ensure the config file can be read.
class powerdns::authoritative (
  String $group = 'pdns',
) inherits powerdns {
  # install the powerdns package
  package { $powerdns::authoritative_package_name:
    ensure => $powerdns::authoritative_package_ensure,
  }

  stdlib::ensure_packages($powerdns::authoritative_extra_packages, { 'ensure' => $powerdns::authoritative_extra_packages_ensure })

  include "powerdns::backends::${powerdns::backend}"

  file { $powerdns::authoritative_config:
    ensure => 'file',
    owner  => 'root',
    group  => $group,
    mode   => '0640',
    before => Service['pdns'],
  }

  service { 'pdns':
    ensure  => running,
    name    => $powerdns::authoritative_service_name,
    enable  => true,
    require => Package[$powerdns::authoritative_package_name],
  }
}
