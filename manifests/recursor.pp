# @summary powerdns recursor
#
# @param forward_zones
#   Hash containing zone => dns servers pairs
#
class powerdns::recursor (
  Hash $forward_zones = $powerdns::forward_zones,
) inherits powerdns {
  package { $powerdns::recursor_package_name:
    ensure => $powerdns::recursor_package_ensure,
  }

  if !empty($forward_zones) {
    $zone_config = "${powerdns::recursor_configdir}/forward_zones.conf"
    file { $zone_config:
      ensure  => file,
      owner   => 'root',
      group   => 0,
      content => template('powerdns/forward_zones.conf.erb'),
      notify  => Service['pdns-recursor'],
    }

    powerdns::config { 'forward-zones-file':
      value => $zone_config,
      type  => 'recursor',
    }
  }

  service { 'pdns-recursor':
    ensure  => running,
    name    => $powerdns::recursor_service_name,
    enable  => true,
    require => Package[$powerdns::recursor_package_name],
  }
}
