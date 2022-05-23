# bind backend for powerdns
class powerdns::backends::bind inherits powerdns {
  # Remove the default simplebind configuration as we prefer to manage PowerDNS
  # consistently across all operating systems. This file is added to Debian
  # based systems due to Debian's policies.
  file { "${::powerdns::params::authoritative_configdir}/pdns.d/pdns.simplebind.conf":
    ensure  => absent,
    require => Package[$::powerdns::params::authoritative_package],
  }

  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'bind',
    type    => 'authoritative',
  }

  powerdns::config { 'bind-config':
    ensure  => present,
    setting => 'bind-config',
    value   => "${::powerdns::params::authoritative_configdir}/named.conf",
    type    => 'authoritative',
    require => Package[$::powerdns::params::authoritative_package],
  }

  file { "${::powerdns::params::authoritative_configdir}/named.conf":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package[$::powerdns::params::authoritative_package],
  }

  file_line { 'powerdns-bind-baseconfig':
    ensure  => present,
    path    => "${::powerdns::params::authoritative_configdir}/named.conf",
    line    => "options { directory \"${::powerdns::params::authoritative_configdir}/named\"; };",
    match   => 'options',
    notify  => Service['pdns'],
    require => File["${::powerdns::params::authoritative_configdir}/named.conf"],
  }

  file { "${::powerdns::params::authoritative_configdir}/named":
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package[$::powerdns::params::authoritative_package],
  }
}
