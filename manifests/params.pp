# powerdns::params
class powerdns::params {
  $authoritative = true
  $recursor = false
  $backend = 'mysql'
  $backend_install = true
  $db_root_password = ''
  $db_username = 'powerdns'
  $db_password = ''
  $db_name = 'powerdns'
  $db_host = 'localhost'
  $custom_repo = false

  case $::operatingsystem {
    'centos': {
      $authoritative_package = 'pdns'
      $authoritative_service = 'pdns'
      $authoritative_config = '/etc/pdns/pdns.conf'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/pdns-recursor/recursor.conf'
    }
    /^(ubuntu|Debian)$/: {
      $authoritative_package = 'pdns-server'
      $authoritative_service = 'pdns'
      $authoritative_config = '/etc/powerdns/pdns.conf'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/powerdns/recursor.conf'
    }
    default: {
      fail("${::operatingsystem} is not supported yet.")
    }
  }
}
