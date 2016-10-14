# powerdns
class powerdns (
    $authorative       = $::powerdns::params::authorative,
    $recursor          = $::powerdns::params::recursor,
    $backend           = $::powerdns::params::backend,
    $backend_install   = $::powerdns::params::backend_install,
    $db_root_password  = $::powerdns::params::db_root_password,
    $db_username       = $::powerdns::params::db_username,
    $db_password       = $::powerdns::params::db_password,
    $db_name           = $::powerdns::params::db_name,
    $db_host           = $::powerdns::params::db_host,
    $custom_repo       = $::powerdns::params::custom_repo,
    $supermaster_query = $::powerdns::params::supermaster_query,
  ) inherits powerdns::params {

  # do some basic checks
  if $authorative == true {
    if $db_root_password == '' { fail("Database root password can't be empty") }
    if $db_username == '' { fail("Database username can't be empty") }
    if $db_password == '' { fail("Database password can't be empty") }
  }

  # Include the required classes
  if ! $custom_repo {
    include ::powerdns::repo
  }

  if $authorative == true {
    include ::powerdns::authorative
  }

  if $recursor == true {
    include ::powerdns::recursor
  }

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