# powerdns::authoritative
class powerdns::authoritative (
) inherits powerdns {
  # install the powerdns package
  package { $powerdns::authoritative_package_name:
    ensure => $powerdns::authoritative_package_ensure,
  }

  stdlib::ensure_packages($powerdns::authoritative_extra_packages, { 'ensure' => $powerdns::authoritative_extra_packages_ensure })

  include "powerdns::backends::${powerdns::backend}"

  # TODO: move owner and group to module data
  file { $powerdns::authoritative_config:
    owner   => 'pdns',
    group   => 'pdns',
    mode    => '0600',
    replace => false,
    require => Package[$powerdns::authoritative_package_name],
  }

  service { 'pdns':
    ensure  => running,
    name    => $powerdns::authoritative_service_name,
    enable  => true,
    require => File[$powerdns::authoritative_config],
  }
}
