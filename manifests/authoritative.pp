# powerdns::authoritative
#
class powerdns::authoritative inherits powerdns {
  # install the powerdns package
  package { $powerdns::authoritative_package_name:
    ensure => $powerdns::authoritative_package_ensure,
  }

  stdlib::ensure_packages($powerdns::authoritative_extra_packages, { 'ensure' => $powerdns::authoritative_extra_packages_ensure })

  include "powerdns::backends::${powerdns::backend}"

  if ($powerdns::authoritative_group != undef) {
    $authoritative_config_parameters = {
      group => $powerdns::authoritative_group,
    }
  } else {
    $authoritative_config_parameters = {}
  }
  file { $powerdns::authoritative_config:
    ensure => 'file',
    owner  => 'root',
    mode   => '0640',
    before => Service['pdns'],
    *      => $authoritative_config_parameters,
  }

  service { 'pdns':
    ensure  => running,
    name    => $powerdns::authoritative_service_name,
    enable  => true,
    require => Package[$powerdns::authoritative_package_name],
  }
}
