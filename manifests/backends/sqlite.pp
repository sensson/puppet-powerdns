# sqlite backend for powerdns
class powerdns::backends::sqlite inherits powerdns {
  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'gsqlite3',
    type    => 'authoritative',
  }

  powerdns::config { 'gsqlite3-database':
    ensure  => present,
    setting => 'gsqlite3-database',
    value   => $::powerdns::db_file,
    type    => 'authoritative',
  }

  # set up the powerdns backend
  package { $::powerdns::params::sqlite_backend_package_name:
    ensure  => installed,
    before  => Service[$::powerdns::params::authoritative_service],
    require => Package[$::powerdns::params::authoritative_package],
  }
  if $::powerdns::backend_install {
    if ! defined(Package[$::powerdns::sqlite_package_name]) {
      package { $::powerdns::sqlite_package_name:
        ensure => installed,
      }
    }
  }
  if $::powerdns::backend_create_tables {
    exec { 'powerdns-sqlite3-create-tables':
      command => "/usr/bin/sqlite3 ${::powerdns::db_file} < ${::powerdns::sqlite_schema_file}",
      unless  => "/usr/bin/test `echo '.tables domains' | sqlite3 ${::powerdns::db_file} | wc -l` -eq 1",
      before  => Service[$::powerdns::params::authoritative_service],
      require => Package[$::powerdns::params::authoritative_package],
    }
  }
}
