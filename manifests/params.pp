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
}