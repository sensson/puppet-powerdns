# Changelog

## v4.0.1 - 2023-09-07

### What's Changed

- Bugfix: fix deprecated use of postgresql_password() by @sircubbi in https://github.com/sensson/puppet-powerdns/pull/161

### New Contributors

- @sircubbi made their first contribution in https://github.com/sensson/puppet-powerdns/pull/161

**Full Changelog**: https://github.com/sensson/puppet-powerdns/compare/v4.0.0...v4.0.1

## v4.0.0 - 2023-08-24

### What's Changed

This version drops support for EOL operating systems and Ruby 2.6.

- Drop EoL module support  by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/156
- pdk: Update 2.5.0->3.0.0 by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/154
- puppetlabs/postgresql: Require 9.x by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/157
- puppetlabs/stdlib: Require 9.x  by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/152
- puppetlabs/mysql: Allow 15.x by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/153
- .fixtures.yml: Migrate to git by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/151
- puppet-strings: autofix by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/155
- puppet/epel: Allow 5.x by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/158
- Add Arch Linux support by @bastelfreak in https://github.com/sensson/puppet-powerdns/pull/159

**Full Changelog**: https://github.com/sensson/puppet-powerdns/compare/v3.0.3...v4.0.0

## v3.0.3 - 2023-05-27

### What's Changed

- Allow newer dependencies by @saz in https://github.com/sensson/puppet-powerdns/pull/150

**Full Changelog**: https://github.com/sensson/puppet-powerdns/compare/v3.0.2...v3.0.3

## v3.0.2 - 2023-04-01

### What's Changed

- chore: update metadata & readme for puppet 7 by @ju5t in https://github.com/sensson/puppet-powerdns/pull/149

**Full Changelog**: https://github.com/sensson/puppet-powerdns/compare/v3.0.1...v3.0.2

## v3.0.1 - 2023-04-01

This release ensures the changelog is updated at Puppet Forge.

**Full Changelog**: https://github.com/sensson/puppet-powerdns/compare/v3.0.0...v3.0.1

## v3.0.0 - 2023-03-31

### What's Changed

- Support Sensitive strings by @deric in https://github.com/sensson/puppet-powerdns/pull/148
- BREAKING: drop Puppet 6 support as this version is EOL since 28-02-2023.

**Full Changelog**: https://github.com/sensson/puppet-powerdns/compare/v2.3.0...v3.0.0

## 2.3.0 and onwards

Our changelog will be published on our [releases page](https://github.com/sensson/puppet-powerdns/releases).

## 2.2.2

Bumps PostgreSQL requirement.

## 2.2.1

Incorrect tag.

## 2.2.0

This release adds support for PowerDNS resources.

### Features

- Add support for PowerDNS resources.
- Support Rocky Linux
- Support PowerDNS 4.6

## 2.1.4

This release adds package_ensure to all backends.

## 2.1.3

This release updates the dependencies and adds support
for PowerDNS 4.5.

### Features

- Add support for PowerDNS 4.5.

## 2.1.2

### Summary

A number of dependency version bumps and a fix for the
sqlite schema on RHEL servers has been added. At the same
time, we're dropping the `develop` branch from this
repository as it confusing for a lot of people and
serves no real purpose here.

## 2.1.1

### Summary

Nothing was changed, but due to an incorrect merge
the data in 2.1.0 became invalid.

## 2.1.0

### Summary

This release adds preliminary support for FreeBSD and
also adds support for PowerDNS 4.4.

### Features

- Preliminary support for FreeBSD.
- Allow additional values to be empty in the config.

### Bugs

- Authoritative and recursor package depend on apt repo (#80)

## 2.0.0

### Summary

This release drops support for EOL operating systems and
Puppet 4. Puppet 5 is now the minimum requirement. It adds
support for Puppet 7.

CI has been switched from Travis CI to Github Actions.

### Features

- Support for Puppet 7

### Other

- Switched from the old stahnma/epel to puppet/epel
- Switched CI to Github Actions

## 1.7.2

### Summary

This release adds PowerDNS 4.3 support and supports CentOS 8.

### Features

- Update allowed puppetlabs/apt requirement to 7.6.0.
- Add support for PowerDNS 4.3
- Add support for CentOS 8

## 1.7.1

### Summary

This release updates stahnma/epel to 2.0.0. This is a first step towards
CentOS 8 support.

### Features

- Update stahnma/epel to 2.0.0.

## 1.7.0

### Summary

This release adds support for PowerDNS 4.2.

### Features

- Add support for PowerDNS 4.2
- Configure the database port in the MySQL-backend
- Dependencies have been updated

## 1.6.0

### Summary

This release adds support for Puppet 6 and includes Oracle Linux 7 in our
acceptance tests. We have dropped tests for Puppet 4.7 due to the required
Rubygem dependencies. We encourage you to upgrade to Puppet 5.10.

### Features

- Support for Puppet 6
- Support for Oracle Linux 7

## 1.5.0

### Summary

This release adds support for Ubuntu 18.04, SQLite backend and allows you to
override the EPEL-repository on RHEL-servers.

### Features

- Support for Ubuntu 18.04.
- Support for SQLite.
- Support for `custom_epel` setting.

### Bugs

- Correct Rubocop dependency and styling.
- Remove default Bind-backend on Debian systems.

## 1.4.0

### Summary

This adds support for LDAP as a backend for PowerDNS.

### Features

- Support for LDAP as backend.

### Bugs

- Remove duplicate packages and settings when `custom_repo` is `true`.
- Document duplicate declaration errors when using both the recursor and
- authoritative service.

## 1.3.0

### Summary

This completes support for PostgreSQL and adds Bind as backend for PowerDNS.

### Features

- Full support for PostgreSQL as backend.
- Support for Bind as backend.
- Support for Debian 9.

## 1.2.3

### Summary

This release reimplements the `$version` parameter.

### Bugs

- The `$version`-functionality was never implemented by accident.
- Update apt id to be a full fingerprint.

## 1.2.2

This release has no code changes. An incorrect file was added to the Forge
and this release is to correct that error.

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
