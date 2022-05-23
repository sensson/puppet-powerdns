# postgresql backend for powerdns
class powerdns::backends::postgresql ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
  if $facts['os']['family'] == 'Debian' {
    # Remove the debconf gpgsql configuration file auto-generated when using the package
    # from Debian repository as it interferes with this module's backend configuration.
    file { "${::powerdns::params::authoritative_configdir}/pdns.d/pdns.local.gpgsql.conf":
      ensure  => absent,
      require => Package[$::powerdns::params::pgsql_backend_package_name],
    }

    # The pdns-server package from the Debian APT repo automatically installs the bind
    # backend package which we do not want when using another backend such as pgsql.
    package { 'pdns-backend-bind':
      ensure  => purged,
      require => Package[$::powerdns::params::authoritative_package],
    }
  }

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
  if $::powerdns::params::pgsql_backend_package_name {
    package { $::powerdns::params::pgsql_backend_package_name:
      ensure  => $package_ensure,
      before  => Service['pdns'],
      require => Package[$::powerdns::params::authoritative_package],
    }
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
