# mysql backend for powerdns
class powerdns::backends::mysql inherits powerdns {
  if $::powerdns::db_name == '' { fail('No database name specified.') }
  if $::powerdns::db_username == '' { fail('No database username specified.') }
  if $::powerdns::db_password == '' { fail('No database password specified.') }

  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'gmysql',
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

  powerdns::config { 'gmysql-supermaster-query':
    ensure  => present,
    setting => 'gmysql-supermaster-query',
    value   => $::powerdns::supermaster_query,
    type    => 'authoritative',
  }

  # set up the powerdns backend
  package { 'pdns-backend-mysql':
    ensure  => installed,
    before  => Service[$::powerdns::params::authoritative_service],
    require => Package[$::powerdns::params::authoritative_package],
  }

  if $::powerdns::backend_install == true {
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

  # make sure the database exists
  mysql::db { $::powerdns::db_name:
    user     => $::powerdns::db_username,
    password => $::powerdns::db_password,
    host     => $::powerdns::db_host,
    grant    => [ 'ALL' ],
  }

  # create tables
  powerdns::backends::mysql::create_table { 'domains':
    database => $::powerdns::db_name,
    create   => template('powerdns/domains.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'records':
    database => $::powerdns::db_name,
    create   => template('powerdns/records.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'supermasters':
    database => $::powerdns::db_name,
    create   => template('powerdns/supermasters.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'domainmetadata':
    database => $::powerdns::db_name,
    create   => template('powerdns/domainmetadata.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'cryptokeys':
    database => $::powerdns::db_name,
    create   => template('powerdns/cryptokeys.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'comments':
    database => $::powerdns::db_name,
    create   => template('powerdns/comments.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'tsigkeys':
    database => $::powerdns::db_name,
    create   => template('powerdns/tsigkeys.sql.erb'),
  }
}
