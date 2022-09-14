# powerdns::params
class powerdns::params {
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
      $recursor_dir = '/etc/pdns-recursor'
      $recursor_config = "${recursor_dir}/recursor.conf"
      $install_packages = []
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
      $recursor_dir = '/etc/powerdns'
      $recursor_config = "${recursor_dir}/recursor.conf"

      case $facts['os']['name'] {
        'Debian': {
          case $facts['os']['release']['major'] {
            '8': {
              $install_packages = []
            }
            default: {
              $install_packages = ['dirmngr']
            }
          }
        }
        'Ubuntu': {
          case $facts['os']['release']['major'] {
            '16.04': {
              $install_packages = []
            }
            default: {
              $install_packages = ['dirmngr']
            }
          }
        }
        default: {
          $install_packages = []
        }
      }
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
      $recursor_dir = '/usr/local/etc/pdns'
      $recursor_config = "${recursor_dir}/recursor.conf"
      $install_packages = []
    }
    default: {
      fail("${facts['os']['family']} is not supported yet.")
    }
  }
}
