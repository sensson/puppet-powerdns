# postgresql backend for powerdns
class powerdns::backends::postgresql inherits powerdns {

  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'gpgsql',
    type    => 'authoritative',
  }

  powerdns::config { 'gpgsql-host':
    ensure  => present,
    setting => 'gpgsql-host',
    value   => $::powerdns::db_host,
    type    => 'authoritative',
  }

  powerdns::config { 'gpgsql-user':
    ensure  => present,
    setting => 'gpgsql-user',
    value   => $::powerdns::db_username,
    type    => 'authoritative',
  }

  powerdns::config { 'gpgsql-password':
    ensure  => present,
    setting => 'gpgsql-password',
    value   => $::powerdns::db_password,
    type    => 'authoritative',
  }

  powerdns::config { 'gpgsql-dbname':
    ensure  => present,
    setting => 'gpgsql-dbname',
    value   => $::powerdns::db_name,
    type    => 'authoritative',
  }

  # set up the powerdns backend
  package { 'pdns-backend-postgresql':
    ensure  => installed,
    before  => Service[$::powerdns::params::authoritative_service],
    require => Package[$::powerdns::params::authoritative_package],
  }

  if $::powerdns::backend_install {
    fail('backend_install isn\'t supported with postgresql yet')
  }

  if $::powerdns::backend_create_tables {
    fail('backend_create_tables isn\'t supported with postgresql yet')
  }
}
