# powerdns::authorative
class powerdns::authorative inherits powerdns {
  # install the powerdns package
  package { $::powerdns::params::authorative_package:
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

  service { $::powerdns::params::authorative_service:
    ensure  => running,
    require => Package[$::powerdns::params::authorative_package],
  }
}