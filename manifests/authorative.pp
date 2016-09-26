# powerdns::authorative
class powerdns::authorative inherits powerdns {

  # enable the authorative powerdns server
  if $powerdns::authorative == true {
    $authorative_install = 'installed'
    $authorative_service = 'running'
  }

  # disable the authorative powerdns server
  if $powerdns::authorative == false {
    $authorative_install = 'absent'
    $authorative_service = 'stopped'
  }

  # install the powerdns package
  package { 'pdns':
    ensure => $authorative_install,
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

  service { 'pdns':
    ensure  => $authorative_service,
    require => Package['pdns'],
  }
}