# powerdns
class powerdns (
    $authorative = true,
    $recursor = false,
    $backend = 'mysql',
    $backend_install = true,

    $db_root_password = '',
    $db_username = 'powerdns',
    $db_password = '',
    $db_name = 'powerdns',
    $db_host = 'localhost',
  ) {

  # do some basic checks
  if $db_root_password == '' { fail("Database root password can't be empty") }
  if $db_username == '' { fail("Database username can't be empty") }
  if $db_password == '' { fail("Database password can't be empty") }

  case $operatingsystem {
    centos: {
      package { 'yum-plugin-priorities':
        ensure => installed,
        before => Yumrepo['powerdns'],
      }

      yumrepo { 'powerdns':
        name => 'powerdns',
        descr => 'PowerDNS repository for PowerDNS Recursor - version 4.0.X',
        baseurl => 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40',
        gpgkey => 'https://repo.powerdns.com/FD380FBB-pub.asc',
        gpgcheck => 1,
        enabled => 1,
        priority => 90,
        includepkgs => 'pdns*',
        before => Package['pdns'],
      }      
    }

    default: {
      fail("$operatingsystem is not supported yet.")
    }
  }

  # Include the required classes
  include powerdns::authorative
  include powerdns::recursor

  # Set up Hiera. Even though it's not necessary to explicitly set $type for the authorative
  # config, it is added for clarity.
  $powerdns_auth_config = hiera('powerdns::auth::config', {})
  $powerdns_auth_defaults = { 'type' => 'authorative' }
  create_resources(powerdns::config, $powerdns_auth_config, $powerdns_auth_defaults)
  
  # Set up Hiera for the recursor.
  $powerdns_recursor_config = hiera('powerdns::recursor::config', {})
  $powerdns_recursor_defaults = { 'type' => 'recursor' }
  create_resources(powerdns::config, $powerdns_recursor_config, $powerdns_recursor_defaults)
}