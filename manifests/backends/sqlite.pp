# sqlite backend for powerdns
class powerdns::backends::sqlite ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
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
  if $::powerdns::params::sqlite_backend_package_name {
    package { $::powerdns::params::sqlite_backend_package_name:
      ensure  => $package_ensure,
      before  => Service['pdns'],
      require => Package[$::powerdns::params::authoritative_package],
    }
  }
  if $::powerdns::backend_install {
    if ! defined(Package[$::powerdns::sqlite_package_name]) {
      package { $::powerdns::sqlite_package_name:
        ensure => $package_ensure,
      }
    }
  }
  if $::powerdns::backend_create_tables {
    file { $::powerdns::db_dir:
      ensure => directory,
      mode   => '0755',
      owner  => 'pdns',
      group  => 'pdns',
    }
    -> file { $::powerdns::db_file:
      ensure => present,
      mode   => '0644',
      owner  => 'pdns',
      group  => 'pdns',
    }
    -> exec { 'powerdns-sqlite3-create-tables':
      command => "/usr/bin/env sqlite3 ${::powerdns::db_file} < ${::powerdns::sqlite_schema_file}",
      unless  => "/usr/bin/env test `echo '.tables domains' | sqlite3 ${::powerdns::db_file} | wc -l` -eq 1",
      before  => Service['pdns'],
      require => Package[$::powerdns::params::authoritative_package],
    }
  }
}
