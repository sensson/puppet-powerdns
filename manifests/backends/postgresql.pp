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
  package { $::powerdns::params::pgsql_backend_package_name:
    ensure  => installed,
    before  => Service[$::powerdns::params::authoritative_service],
    require => Package[$::powerdns::params::authoritative_package],
  }

  if $::powerdns::backend_install {
    if ! defined(Class['::postgresql::server']) {
      class { '::postgresql::server':
        postgres_password => $::powerdns::db_root_password,
      }
    }
  }

  if $::powerdns::backend_create_tables {
    postgresql::server::db { $::powerdns::db_name:
      user     => $::powerdns::db_username,
      password => postgresql_password($::powerdns::db_username, $::powerdns::db_password),
      require  => Package[$::powerdns::params::pgsql_backend_package_name],
    }

    # define connection settings for powerdns user in order to create tables
    $connection_settings_powerdns = {
      'PGUSER'     => $::powerdns::db_username,
      'PGPASSWORD' => $::powerdns::db_password,
      'PGHOST'     => $::powerdns::db_host,
      'PGDATABASE' => $::powerdns::db_name,
    }

    postgresql_psql { 'Load SQL schema':
      connect_settings => $connection_settings_powerdns,
      command          => "\\i ${::powerdns::pgsql_schema_file}",
      unless           => "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'domains'",
      require          => Postgresql::Server::Db[$::powerdns::db_name],
    }
  }
}
