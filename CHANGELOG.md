## 1.2.1

This is a minor release which removes unused template files.

## 1.2.0

### Summary

PowerDNS 4.1 is now the default version. You can switch versions through a
newly introduced parameter `$version`. This will change the repositories to
the latest version but it will not update PowerDNS for you, nor does it make
any required database changes.

### Features
- Add version support. This also includes the EPEL-repository on RHEL.
- Use the MySQL database schema as provided by PowerDNS.

## 1.1.0

### Features
- Use Puppet 4 datatypes.
- Support for `backend_create_tables`, making database management optional.
- (Basic) Support for PostgreSQL.
- Support all RedHat flavours.
- Bump apt support to < 5.0.0

### Bugs
- Contain private subclasses
- Set `gmysql-host` when managing MySQL.
- Allow both String and Integer as value for `powerdns::config` values.

## 1.0.1

### Summary

This marks the long overdue stable release of the PowerDNS module. The 1.0.0
release was missing these release notes so we immediately released 1.0.1.

We have dropped support for Puppet 3 in this release.

### Features
- Default to Puppet 4.
- Support removing config with `ensure => absent`.
- Use Puppet 4 data types in `config.pp`.

### Bugs
- Rubocop updates caused tests to fail.
- `allow-notify-from` was not allowed to be empty.

## 0.0.12

### Summary

We have dropped Ruby 1.9.3 from our tests and added Rubocop coverage to
ensure we write decent code where possible.

### Features
- Rubocop coverage for all Ruby code in this module.

### Bugfixes
- The README wrongly mentioned listen-address instead of local-address

## 0.0.11

### Summary

This release officially drops support for Puppet 2.

#### Features
- Allow the `only-notify` PowerDNS configuration setting to be empty.
- Improved error messages on failure when setting configurations.

#### Bugfixes
- Added the recursor to our test suite.
- Update Ruby versions in our test suite.

## 0.0.10

### Summary

Version bump to update forge.puppet.com.

## 0.0.9

### Summary

This release adds 1 feature.

#### Features
- Added `enable` for the recursor and authoritative service

## 0.0.8

### Summary

This release adds 1 feature and solves 3 bugs.

#### Features
- Added support for `ensure` to the recursor and authoritative package

#### Bugfixes
- Make powerdns::config more specific
- Pin rake tests to simplecov-console to 0.3.1
- Only fail on `db_root_password` if `backend_install` is true

## 0.0.7

### Summary

This release adds support for Debian 8.

#### Features
- Added support for Debian 8

#### Bugfixes
- Only try to set config if the corresponding services are used
- Removed our default supermaster-query setting as it was causing issues on 4.x

## 0.0.6

### Summary

This release adds 3 features and solves 1 bug.

#### Features
- Added support for a custom supermaster-query
- Added support to disable the installation of PowerDNS packages
- Added support to disable the configuration of the PowerDNS repositories

#### Bugfixes
- Renamed authorative to authoritative according to the PowerDNS manual

## 0.0.5

### Summary

This release adds support for Ubuntu 16.04.

#### Features
- Added support for Ubuntu 16.04

## 0.0.4

### Summary

This release adds support for Ubuntu 14.04 and CentOS 6.

#### Features
- Added support for Ubuntu 14.04
- Added support for CentOS 6
- Improved the test suite and included support for Beaker

#### Bugfixes
- Made sure the repository is added before pdns-recursor is installed

## 0.0.3

### Summary

This release adds spec tests.

#### Features
- Added spec tests

#### Bugfixes
- Changed the root_home reference when creating database tables

## 0.0.2

### Summary

This release solves one bug.

#### Bugfixes
- Added a dependency on the pdns package when configuring MySQL

## 0.0.1

### Summary

Initial release.
