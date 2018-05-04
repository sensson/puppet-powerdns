# bind backend for powerdns
class powerdns::backends::bind inherits powerdns {
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
    value   => '/etc/powerdns/bindbackend.conf',
    type    => 'authoritative',
  }

  # set up the powerdns backend
  package { 'pdns-backend-bind':
    ensure  => installed,
    before  => Service[$::powerdns::params::authoritative_service],
    require => Package[$::powerdns::params::authoritative_package],
  }

  file { "$::powerdns::params::authoritative_configdirbindbackend/bindbackend.conf": 
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

  file { "$::powerdns::params::authoritative_configdirbindbackend/bind":
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  file_line { "powerdns-bind-baseconfig":
    ensure            => present,
    path              => "$::powerdns::params::authoritative_configdirbindbackend/bindbackend.conf",
    line              => 'options { directory "/etc/powerdns/bind"; };',
    match             => 'options',
    require           => Package['pdns-backend-bind'],
    notify            => Service[$::powerdns::params::authoritative_service],
  }

}
