# mysql backend for powerdns
class powerdns::backends::mysql ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
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
    value   => $powerdns::db_host,
    type    => 'authoritative',
  }

  powerdns::config { 'gmysql-port':
    ensure  => present,
    setting => 'gmysql-port',
    value   => $powerdns::db_port,
    type    => 'authoritative',
  }

  powerdns::config { 'gmysql-user':
    ensure  => present,
    setting => 'gmysql-user',
    value   => $powerdns::db_username,
    type    => 'authoritative',
  }

  $_db_password = $powerdns::db_password =~ Sensitive ? {
    true => $powerdns::db_password.unwrap,
    false => $powerdns::db_password
  }

  if $_db_password {
    powerdns::config { 'gmysql-password':
      ensure  => present,
      setting => 'gmysql-password',
      value   => $_db_password,
      type    => 'authoritative',
    }
  }

  powerdns::config { 'gmysql-dbname':
    ensure  => present,
    setting => 'gmysql-dbname',
    value   => $powerdns::db_name,
    type    => 'authoritative',
  }

  if $powerdns::params::mysql_backend_package_name {
    # set up the powerdns backend
    package { $powerdns::params::mysql_backend_package_name:
      ensure  => $package_ensure,
      before  => Service['pdns'],
      require => Package[$powerdns::params::authoritative_package],
    }
  }
  if $powerdns::backend_install {
    # mysql database
    if ! defined(Class['mysql::server']) {
      $_db_root_password = $powerdns::db_root_password =~ Sensitive ? {
        true => $powerdns::db_root_password.unwrap,
        false => $powerdns::db_root_password
      }

      class { 'mysql::server':
        root_password      => $_db_root_password,
        create_root_my_cnf => true,
      }
    }

    if ! defined(Class['mysql::server::account_security']) {
      class { 'mysql::server::account_security': }
    }
  }

  if $powerdns::backend_create_tables and $_db_password {
    # make sure the database exists
    mysql::db { $powerdns::db_name:
      user     => $powerdns::db_username,
      password => $_db_password,
      host     => $powerdns::db_host,
      grant    => ['ALL'],
      sql      => [$powerdns::mysql_schema_file],
      require  => Package[$powerdns::params::mysql_backend_package_name],
    }
  }
}
