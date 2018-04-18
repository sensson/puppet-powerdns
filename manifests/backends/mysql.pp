# mysql backend for powerdns
class powerdns::backends::mysql inherits powerdns {
  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'gmysql',
    type    => 'authoritative',
  }

  powerdns::config { 'gmysql-host':
    ensure  => present,
    setting => 'gmysql-host',
    value   => $::powerdns::db_host,
    type    => 'authoritative',
  }

  powerdns::config { 'gmysql-user':
    ensure  => present,
    setting => 'gmysql-user',
    value   => $::powerdns::db_username,
    type    => 'authoritative',
  }

  powerdns::config { 'gmysql-password':
    ensure  => present,
    setting => 'gmysql-password',
    value   => $::powerdns::db_password,
    type    => 'authoritative',
  }

  powerdns::config { 'gmysql-dbname':
    ensure  => present,
    setting => 'gmysql-dbname',
    value   => $::powerdns::db_name,
    type    => 'authoritative',
  }

  # set up the powerdns backend
  package { 'pdns-backend-mysql':
    ensure  => installed,
    before  => Service[$::powerdns::params::authoritative_service],
    require => Package[$::powerdns::params::authoritative_package],
  }

  if $::powerdns::backend_install {
    # mysql database
    if ! defined(Class['::mysql::server']) {
      class { '::mysql::server':
        root_password      => $::powerdns::db_root_password,
        create_root_my_cnf => true,
      }
    }

    if ! defined(Class['::mysql::server::account_security']) {
      class { '::mysql::server::account_security': }
    }
  }

  if $::powerdns::backend_create_tables {
    # make sure the database exists
    mysql::db { $::powerdns::db_name:
      user     => $::powerdns::db_username,
      password => $::powerdns::db_password,
      host     => $::powerdns::db_host,
      grant    => [ 'ALL' ],
      sql      => $::powerdns::mysql_schema_file,
      require  => Package['pdns-backend-mysql'],
    }
  }
}
