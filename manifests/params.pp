# powerdns::params
class powerdns::params {
  $authorative = true
  $recursor = false
  $backend = 'mysql'
  $backend_install = true
  $db_root_password = ''
  $db_username = 'powerdns'
  $db_password = ''
  $db_name = 'powerdns'
  $db_host = 'localhost'
  $custom_repo = false
  $supermaster_query = 'select account from supermasters where ip=\'%s\''

  case $::operatingsystem {
    'centos': {
      $authorative_package = 'pdns'
      $authorative_service = 'pdns'
      $authorative_config = '/etc/pdns/pdns.conf'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/pdns-recursor/recursor.conf'
    }
    'ubuntu': {
      $authorative_package = 'pdns-server'
      $authorative_service = 'pdns'
      $authorative_config = '/etc/powerdns/pdns.conf'
      $recursor_package = 'pdns-recursor'
      $recursor_service = 'pdns-recursor'
      $recursor_config = '/etc/powerdns/recursor.conf'
    }
    default: {
      fail("${::operatingsystem} is not supported yet.")
    }
  }
}