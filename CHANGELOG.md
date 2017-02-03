## 0.0.7

### Summary

This release adds support for Debian 8.

#### Features
- Added support for Debian 8

#### Bugfixes
- Only try to set config if the corresponding services are used
- Removed our default supermaster-query setting as it was causing issues on 4.x.

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