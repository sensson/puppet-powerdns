# powerdns::authoritative
class powerdns::authoritative ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
  # install the powerdns package
  package { $::powerdns::params::authoritative_package:
    ensure => $package_ensure,
  }

  # install the right backend
  case $::powerdns::backend {
    'mysql': {
      include powerdns::backends::mysql
    }
    'postgresql': {
      include powerdns::backends::postgresql
    }
    default: {
      fail("${::powerdns::backend} is not supported. We only support 'mysql' and 'postgresql' at the moment.")
    }
  }

  service { $::powerdns::params::authoritative_service:
    ensure  => running,
    enable  => true,
    require => Package[$::powerdns::params::authoritative_package],
  }
}
