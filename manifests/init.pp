# powerdns
#
# @param autoprimaries
#   Hash of autoprimaries the ensurce (with resource powerdns_autoprimary)
# @param purge_autoprimaries
#   Set this to true if you like to purge all autoprimaries not managed with puppet
# @param lmdb_filename
#   Filename for the lmdb database
# @param lmdb_schema_version
#   Maximum allowed schema version to run on this DB. If a lower version is found, auto update is performed
# @param lmdb_shards
#   Records database will be split into this number of shards
# @param lmdb_sync_mode
#   Sync mode for LMDB. One of 'nosync', 'sync', 'nometasync', 'mapasync'
#
# @param authoritative_group
#   If present, this group will be set on the authoritative server pdns.conf file. 
#
class powerdns (
  String[1] $authoritative_package_name,
  String[1] $authoritative_package_ensure,
  Optional[Array[String[1]]] $authoritative_extra_packages,
  String[1] $authoritative_extra_packages_ensure,
  String[1] $authoritative_service_name,
  Stdlib::Absolutepath $authoritative_configdir,
  Stdlib::Absolutepath $authoritative_config,
  Pattern[/4\.[0-9]+/] $authoritative_version,
  Stdlib::Absolutepath $db_dir,
  Stdlib::Absolutepath $db_file,
  Stdlib::Absolutepath $mysql_schema_file,
  Stdlib::Absolutepath $pgsql_schema_file,
  Stdlib::Absolutepath $sqlite_schema_file,
  String[1] $recursor_package_name,
  String[1] $recursor_package_ensure,
  String[1] $recursor_service_name,
  Stdlib::Absolutepath $recursor_configdir,
  Stdlib::Absolutepath $recursor_config,
  Pattern[/[4,5]\.[0-9]+/] $recursor_version,
  String[1] $sqlite_package_name,
  Optional[String[1]] $mysql_backend_package_name,
  Optional[String[1]] $ldap_backend_package_name,
  Optional[String[1]] $pgsql_backend_package_name,
  Optional[String[1]] $sqlite_backend_package_name,
  Optional[String[1]] $lmdb_backend_package_name,
  Boolean $authoritative = true,
  Boolean $recursor = false,
  Powerdns::Backends $backend = 'mysql',
  Boolean $backend_install = true,
  Boolean $backend_create_tables = true,
  Powerdns::Secret $db_root_password = undef,
  String[1] $db_username = 'powerdns',
  Powerdns::Secret $db_password = undef,
  String[1] $db_name = 'powerdns',
  Stdlib::Host $db_host = 'localhost',
  Stdlib::Port $db_port = 3306,
  Boolean $require_db_password = true,
  String[1] $ldap_host = 'ldap://localhost/',
  Optional[String[1]] $ldap_basedn = undef,
  Powerdns::LdapMethod $ldap_method = 'strict',
  Optional[String[1]] $ldap_binddn = undef,
  Powerdns::Secret $ldap_secret = undef,
  Stdlib::Absolutepath $lmdb_filename = '/var/lib/powerdns/pdns.lmdb',
  Optional[Integer] $lmdb_schema_version = undef,
  Optional[Integer] $lmdb_shards = undef,
  Powerdns::LmdbSyncMode $lmdb_sync_mode = undef,
  Boolean $custom_repo = false,
  Boolean $custom_epel = false,
  Hash $forward_zones = {},
  Powerdns::Autoprimaries $autoprimaries = {},
  Boolean $purge_autoprimaries = false,
  Optional[String[1]] $authoritative_group = undef,
) {
  # Do some additional checks. In certain cases, some parameters are no longer optional.
  if $authoritative {
    if $require_db_password and !($powerdns::backend in ['bind', 'ldap', 'sqlite', 'lmdb']) {
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

  if $purge_autoprimaries {
    resources { 'powerdns_autoprimary':
      purge => true,
    }
  }
  create_resources('powerdns_autoprimary', $autoprimaries)
}
