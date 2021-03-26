# powerdns::params
class powerdns::params {
  $authoritative = true
  $recursor = false
  $backend = 'mysql'
  $backend_create_tables = true
  $db_root_password = undef
  $db_username = 'powerdns'
  $db_password = undef
  $db_name = 'powerdns'
  $db_host = 'localhost'
  $db_port = 3306
  $ldap_host = 'ldap://localhost/'
  $ldap_basedn = undef
  $ldap_method = 'strict'
  $ldap_binddn = undef
  $ldap_secret = undef
  $custom_repo = false
  $custom_epel = false
  $default_package_ensure = installed
  $version = '4.2'

  case $facts['os']['family'] {
    'RedHat': {
      $authoritative_package = 'pdns'
      $authoritative_service = 'pdns'
      $authoritative_config = '/etc/pdns/pdns.conf'
      $backend_install = true
      $db_dir = '/var/lib/powerdns'
      $db_file = "${db_dir}/powerdns.sqlite3"
      $mysql_backend_package_name = 'pdns-backend-mysql'
      $ldap_backend_package_name = 'pdns-backend-ldap'
      $pgsql_backend_package_name = 'pdns-backend-postgresql'
      $service_provider = 'systemd'
      $sqlite_backend_package_name = 'pdns-backend-sqlite'
      $mysql_schema_file = '/usr/share/doc/pdns-backend-mysql-4.?.?/schema.mysql.sql'
      $pgsql_schema_file = '/usr/share/doc/pdns-backend-postgresql-4.?.?/schema.pgsql.sql'
      $sqlite_schema_file = '/usr/share/doc/pdns-backend-sqlite-4.?.?/schema.sqlite.sql'
      $sqlite_package_name = 'sqlite'
      $authoritative_configdir = '/etc/pdns'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/pdns-recursor/recursor.conf'
    }
    'Debian': {
      $authoritative_package = 'pdns-server'
      $authoritative_service = 'pdns'
      $authoritative_config = '/etc/powerdns/pdns.conf'
      $backend_install = true
      $db_dir = '/var/lib/powerdns'
      $db_file = "${db_dir}/powerdns.sqlite3"
      $mysql_backend_package_name = 'pdns-backend-mysql'
      $ldap_backend_package_name = 'pdns-backend-ldap'
      $pgsql_backend_package_name = 'pdns-backend-pgsql'
      $sqlite_backend_package_name = 'pdns-backend-sqlite3'
      $mysql_schema_file = '/usr/share/doc/pdns-backend-mysql/schema.mysql.sql'
      $pgsql_schema_file = '/usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql'
      $service_provider = 'systemd'
      $sqlite_schema_file = '/usr/share/doc/pdns-backend-sqlite3/schema.sqlite3.sql'
      $sqlite_package_name = 'sqlite3'
      $authoritative_configdir = '/etc/powerdns'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/powerdns/recursor.conf'
    }
    'FreeBSD': {
      $authoritative_package = 'powerdns'
      $authoritative_service = 'pdns'
      $authoritative_config = '/usr/local/etc/pdns/pdns.conf'
      $backend_install = true
      $db_dir = '/var/db/powerdns'
      $db_file = "${db_dir}/powerdns.sqlite3"
      $mysql_backend_package_name = 'pdns-backend-mysql'
      $ldap_backend_package_name = undef
      $pgsql_backend_package_name = undef
      $sqlite_backend_package_name = undef
      $mysql_schema_file = '/usr/local/share/doc/powerdns/schema.mysql.sql'
      $pgsql_schema_file = '/usr/local/share/doc/powerdns/schema.pgsql.sql'
      $service_provider = 'freebsd'
      $sqlite_schema_file = '/usr/local/share/doc/powerdns/schema.sqlite3.sql'
      $sqlite_package_name = 'sqlite3'
      $authoritative_configdir = '/usr/local/etc/pdns'
      $recursor_package = 'powerdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/usr/local/etc/pdns/recursor.conf'
    }
    default: {
      fail("${facts['os']['family']} is not supported yet.")
    }
  }
}
