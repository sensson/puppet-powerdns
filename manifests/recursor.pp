# the powerdns recursor
class powerdns::recursor ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
  package { $::powerdns::params::recursor_package:
    ensure => $package_ensure,
  }

  service { 'pdns-recursor':
    ensure   => running,
    name     => $::powerdns::params::recursor_service,
    enable   => true,
    provider => [$::powerdns::params::service_provider],
    require  => Package[$::powerdns::params::recursor_package],
  }
}
