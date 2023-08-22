# powerdns
class powerdns (
  Boolean                    $authoritative                      = true,
  Boolean                    $recursor                           = false,
  Enum['ldap', 'mysql', 'bind', 'postgresql', 'sqlite'] $backend = 'mysql',
  Boolean                    $backend_install                    = true,
  Boolean                    $backend_create_tables              = true,
  Powerdns::Secret           $db_root_password                   = undef,
  String[1]                  $db_username                        = 'powerdns',
  Powerdns::Secret           $db_password                        = undef,
  String[1]                  $db_name                            = 'powerdns',
  String[1]                  $db_host                            = 'localhost',
  Integer[1]                 $db_port                            = 3306,
  String[1]                  $db_dir                             = $powerdns::params::db_dir,
  String[1]                  $db_file                            = $powerdns::params::db_file,
  Boolean                    $require_db_password                = true,
  String[1]                  $ldap_host                          = 'ldap://localhost/',
  Optional[String[1]]        $ldap_basedn                        = undef,
  String[1]                  $ldap_method                        = 'strict',
  Optional[String[1]]        $ldap_binddn                        = undef,
  Powerdns::Secret           $ldap_secret                        = undef,
  Boolean                    $custom_repo                        = false,
  Boolean                    $custom_epel                        = false,
  Pattern[/4\.[0-9]+/]       $version                            = $powerdns::params::version,
  String[1]                  $mysql_schema_file                  = $powerdns::params::mysql_schema_file,
  String[1]                  $pgsql_schema_file                  = $powerdns::params::pgsql_schema_file,
  Hash                       $forward_zones                      = {},
) inherits powerdns::params {
  # Do some additional checks. In certain cases, some parameters are no longer optional.
  if $authoritative {
    if ($powerdns::backend != 'bind') and ($powerdns::backend != 'ldap') and ($powerdns::backend != 'sqlite') and $require_db_password {
      assert_type(Variant[String[1], Sensitive[String[1]]], $db_password) |$expected, $actual| {
        fail("'db_password' must be a non-empty string when 'authoritative' == true")
      }
      if $backend_install {
        assert_type(Variant[String[1], Sensitive[String[1]]], $db_root_password) |$expected, $actual| {
          fail("'db_root_password' must be a non-empty string when 'backend_install' == true")
        }
      }
    }
    if $backend_create_tables and $backend == 'mysql' {
      assert_type(Variant[String[1], Sensitive[String[1]]], $db_root_password) |$expected, $actual| {
        fail("On MySQL 'db_root_password' must be a non-empty string when 'backend_create_tables' == true")
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
