# powerdns
class powerdns (
  Boolean                    $authoritative                      = $::powerdns::params::authoritative,
  Boolean                    $recursor                           = $::powerdns::params::recursor,
  Enum['ldap', 'mysql', 'bind', 'postgresql', 'sqlite'] $backend = $::powerdns::params::backend,
  Boolean                    $backend_install                    = $::powerdns::params::backend_install,
  Boolean                    $backend_create_tables              = $::powerdns::params::backend_create_tables,
  Optional[String[1]]        $db_root_password                   = $::powerdns::params::db_root_password,
  Optional[String[1]]        $db_username                        = $::powerdns::params::db_username,
  Optional[String[1]]        $db_password                        = $::powerdns::params::db_password,
  Optional[String[1]]        $db_name                            = $::powerdns::params::db_name,
  Optional[String[1]]        $db_host                            = $::powerdns::params::db_host,
  Optional[Integer[1]]       $db_port                            = $::powerdns::params::db_port,
  Optional[String[1]]        $db_dir                             = $::powerdns::params::db_dir,
  Optional[String[1]]        $db_file                            = $::powerdns::params::db_file,
  Optional[String[1]]        $ldap_host                          = $::powerdns::params::ldap_host,
  Optional[String[1]]        $ldap_basedn                        = $::powerdns::params::ldap_basedn,
  Optional[String[1]]        $ldap_method                        = $::powerdns::params::ldap_method,
  Optional[String[1]]        $ldap_binddn                        = $::powerdns::params::ldap_binddn,
  Optional[String[1]]        $ldap_secret                        = $::powerdns::params::ldap_secret,
  Optional[String[1]]        $service_provider                   = $::powerdns::params::service_provider,
  Boolean                    $custom_repo                        = $::powerdns::params::custom_repo,
  Boolean                    $custom_epel                        = $::powerdns::params::custom_epel,
  Pattern[/4\.(0|1|2|3|4|5|6)/] $version                         = $::powerdns::params::version,
  String[1]                  $mysql_schema_file                  = $::powerdns::params::mysql_schema_file,
  String[1]                  $pgsql_schema_file                  = $::powerdns::params::pgsql_schema_file,
) inherits powerdns::params {

  # Do some additional checks. In certain cases, some parameters are no longer optional.
  if $authoritative {
    if ($::powerdns::backend != 'bind') and ($::powerdns::backend != 'ldap') and ($::powerdns::backend != 'sqlite') {
      assert_type(String[1], $db_password) |$expected, $actual| {
        fail("'db_password' must be a non-empty string when 'authoritative' == true")
      }
      if $backend_install {
        assert_type(String[1], $db_root_password) |$expected, $actual| {
          fail("'db_root_password' must be a non-empty string when 'backend_install' == true")
        }
      }
    }
  }

  # Include the required classes
  unless $custom_repo {
    contain powerdns::repo
  }

  if $authoritative {
    contain powerdns::authoritative

    # Set up Hiera. Even though it's not necessary to explicitly set $type for the authoritative
    # config, it is added for clarity.
    $powerdns_auth_config = lookup('powerdns::auth::config', Hash, 'deep', {})
    $powerdns_auth_defaults = { 'type' => 'authoritative' }
    create_resources(powerdns::config, $powerdns_auth_config, $powerdns_auth_defaults)
  }

  if $recursor {
    contain powerdns::recursor

    # Set up Hiera for the recursor.
    $powerdns_recursor_config = lookup('powerdns::recursor::config', Hash, 'deep', {})
    $powerdns_recursor_defaults = { 'type' => 'recursor' }
    create_resources(powerdns::config, $powerdns_recursor_config, $powerdns_recursor_defaults)
  }
}
