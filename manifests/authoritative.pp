# powerdns::authoritative
class powerdns::authoritative (
  $package_ensure = $powerdns::params::default_package_ensure,
  Optional[Array[String]] $install_packages = $powerdns::install_packages,
) inherits powerdns {
  # install the powerdns package
  package { $powerdns::params::authoritative_package:
    ensure => $package_ensure,
  }

  stdlib::ensure_packages($install_packages)

  $supported_backends = [
    'mysql',
    'bind',
    'postgresql',
    'ldap',
    'sqlite',
    'lmdb',
  ]

  unless $powerdns::backend in $supported_backends {
    fail("${powerdns::backend} is not supported. We only support ${supported_backends.join(', ')} at the moment.")
  }

  include "powerdns::backends::${powerdns::backend}"

  service { 'pdns':
    ensure  => running,
    name    => $powerdns::params::authoritative_service,
    enable  => true,
    require => Package[$powerdns::params::authoritative_package],
  }
}
