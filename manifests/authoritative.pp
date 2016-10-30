# powerdns::authoritative
class powerdns::authoritative inherits powerdns {
  # install the powerdns package
  package { $::powerdns::params::authoritative_package:
    ensure => installed,
  }

  # install the right backend
  case $::powerdns::backend {
    'mysql': {
      include ::powerdns::backends::mysql
    }
    default: {
      fail("${::powerdns::backend} is not supported. We only support 'mysql' at the moment.")
    }
  }

  service { $::powerdns::params::authoritative_service:
    ensure  => running,
    require => Package[$::powerdns::params::authoritative_package],
  }
}
