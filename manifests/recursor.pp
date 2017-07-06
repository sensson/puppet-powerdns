# the powerdns recursor
class powerdns::recursor ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
  package { $::powerdns::params::recursor_package:
    ensure => $package_ensure,
  }

  service { $::powerdns::params::recursor_service:
    enable  => true,
    ensure  => running,
    enable  => true,
    require => Package[$::powerdns::params::recursor_package],
  }
}
