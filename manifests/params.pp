# powerdns::params
class powerdns::params {
  $authoritative = true
  $recursor = false
  $backend = 'mysql'
  $backend_install = true
  $backend_create_tables = true
  $db_root_password = undef
  $db_username = 'powerdns'
  $db_password = undef
  $db_name = 'powerdns'
  $db_host = 'localhost'
  $custom_repo = false
  $default_package_ensure = installed
  $version = '4.1'
  $mysql_schema_file = '/usr/share/doc/pdns-backend-mysql-4.?.?/schema.mysql.sql'

  case $facts['os']['family'] {
    'RedHat': {
      $authoritative_package = 'pdns'
      $authoritative_service = 'pdns'
      $authoritative_config = '/etc/pdns/pdns.conf'
      $authoritative_configdir = '/etc/pdns'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/pdns-recursor/recursor.conf'
    }
    'Debian': {
      $authoritative_package = 'pdns-server'
      $authoritative_service = 'pdns'
      $authoritative_config = '/etc/powerdns/pdns.conf'
      $authoritative_configdir = '/etc/powerdns'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/powerdns/recursor.conf'
    }
    default: {
      fail("${facts['os']['family']} is not supported yet.")
    }
  }
}
