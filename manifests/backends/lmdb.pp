# lmdb backend for powerdns
class powerdns::backends::lmdb (
) inherits powerdns {
  if $facts['os']['family'] == 'Debian' {
    # The pdns-server package from the Debian APT repo automatically installs the bind
    # backend package which we do not want when using another backend such as ldap.
    package { 'pdns-backend-bind':
      ensure  => purged,
      require => Package[$powerdns::authoritative_package_name],
    }

    # The pdns-backend-lmdb package installs a configuration file that conflicts with this module's backend configuration.
    file { "${powerdns::authoritative_configdir}/pdns.d/lmdb.conf":
      ensure  => absent,
      require => Package[$powerdns::lmdb_backend_package_name],
      before  => Service['pdns'],
    }
  }

  $options = {
    'launch'              => 'lmdb',
    'lmdb-filename'       => $powerdns::lmdb_filename,
    'lmdb-schema-version' => $powerdns::lmdb_schema_version,
    'lmdb-shards'         => $powerdns::lmdb_shards,
    'lmdb-sync-mode'      => $powerdns::lmdb_sync_mode,
  }.delete_undef_values()

  $options.each |$key, $value| {
    powerdns::config { $key:
      ensure  => present,
      setting => $key,
      value   => $value,
      type    => 'authoritative',
    }
  }

  if $powerdns::lmdb_backend_package_name {
    # set up the powerdns backend
    package { $powerdns::lmdb_backend_package_name:
      ensure  => $powerdns::authoritative_package_ensure,
      before  => Service['pdns'],
      require => Package[$powerdns::authoritative_package_name],
    }
  }

  if $powerdns::backend_install {
    fail('backend_install is not supported with lmdb')
  }

  if $powerdns::backend_create_tables {
    fail('backend_create_tables is not supported with lmdb')
  }
}
