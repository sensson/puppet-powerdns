# bind backend for powerdns
class powerdns::backends::bind inherits powerdns {
  # Remove the default simplebind configuration as we prefer to manage PowerDNS
  # consistently across all operating systems. This file is added to Debian
  # based systems due to Debian's policies.
  file { "${powerdns::authoritative_configdir}/pdns.d/pdns.simplebind.conf":
    ensure  => absent,
    require => Package[$powerdns::authoritative_package_name],
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
    value   => "${powerdns::authoritative_configdir}/named.conf",
    type    => 'authoritative',
    require => Package[$powerdns::authoritative_package_name],
  }

  file { "${powerdns::authoritative_configdir}/named.conf":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 0,
    require => Package[$powerdns::authoritative_package_name],
  }

  file_line { 'powerdns-bind-baseconfig':
    ensure  => present,
    path    => "${powerdns::authoritative_configdir}/named.conf",
    line    => "options { directory \"${powerdns::authoritative_configdir}/named\"; };",
    match   => 'options',
    notify  => Service['pdns'],
    require => File["${powerdns::authoritative_configdir}/named.conf"],
  }

  file { "${powerdns::authoritative_configdir}/named":
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 0,
    require => Package[$powerdns::authoritative_package_name],
  }
}
