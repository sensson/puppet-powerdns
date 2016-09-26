# the powerdns recursor
class powerdns::recursor inherits powerdns {
  # enable the authorative powerdns server
  if $::powerdns::recursor == true {
    $recursor_install = 'installed'
    $recursor_service = 'running'
  }

  # disable the authorative powerdns server
  if $::powerdns::recursor == false {
    $recursor_install = 'absent'
    $recursor_service = 'stopped'
  }

  package { 'pdns-recursor':
    ensure => $recursor_install,
  }

  service { 'pdns-recursor':
    ensure  => $recursor_service,
    require => Package['pdns-recursor'],
  }
}