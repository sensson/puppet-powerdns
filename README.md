# PowerDNS

[![Build Status](https://travis-ci.org/sensson/puppet-powerdns.svg?branch=master)](https://travis-ci.org/sensson/puppet-powerdns) [![Puppet Forge](https://img.shields.io/puppetforge/v/sensson/powerdns.svg?maxAge=2592000?style=plastic)](https://forge.puppet.com/sensson/powerdns)

This module can be used to configure both the recursor and authoritative
PowerDNS 4 server. It doesn't intend to support PowerDNS 2 or 3 but the
module supports Puppet 4 and 5.

## Examples

### Installation and configuration

This will install the authoritative PowerDNS server which includes the
MySQL server and the management of the database and its tables. This is
the bare minimum.

```puppet
class { 'powerdns':
  db_password      => 's0m4r4nd0mp4ssw0rd',
  db_root_password => 'v3rys3c4r3',
}
```

If you want to install both the recursor and the authoritative service on the
same server it is recommended to have the services listen on their own IP
address. The example below needs to be adjusted to use the ip addresses of your
server.

This may fail the first time on Debian-based distro's.

```puppet
powerdns::config { 'authoritative-local-address':
  type    => 'authoritative',
  setting => 'local-address',
  value   => '127.0.0.1',
}
powerdns::config { 'recursor-local-address':
  type    => 'recursor',
  setting => 'local-address',
  value   => '127.0.0.2',
}
class { 'powerdns':
  db_password      => 's0m4r4nd0mp4ssw0rd',
  db_root_password => 'v3rys3c4r3',
  recursor         => true,
}
```

### Backends

The default backend is MySQL. It also comes with support for PostgreSQL, Bind,
LDAP and SQLite.

If you don't specify the backend it assumes you will use MySQL.

```puppet
class { 'powerdns':
  backend     => 'mysql',
  db_password => 's0m4r4nd0mp4ssw0rd',
}
```

To use PostgreSQL set `backend` to `postgresql`.

```puppet
class { 'powerdns':
  backend     => 'postgresql',
  db_password => 's0m4r4nd0mp4ssw0rd',
}
```

To use Bind you must set `backend_install` and `backend_create_tables` to
false. For example:

```puppet
class { 'powerdns':
  backend               => 'bind',
  backend_install       => false,
  backend_create_tables => false,
}
```

To use LDAP you must set `backend_install` and `backend_create_tables` to
false. For example:

```puppet
class { 'powerdns':
  backend               => 'ldap',
  backend_install       => false,
  backend_create_tables => false,
}
```

To use SQLite you must set `backend` to `sqlite`. Ensure that the `pdns` user
has write permissions to directory holding database file. For example:

```puppet
class { 'powerdns':
  backend => 'sqlite',
  db_file => '/opt/powerdns.sqlite3',
}
```

## Reference

### Parameters

#### powerdns

We provide a number of configuration options to change particular settings
or to override our defaults when required.

##### `authoritative`

Install the PowerDNS authoritative server. Defaults to true.

##### `recursor`

Install the PowerDNS recursor. Defaults to false.

##### `backend`

Choose a backend for the authoritative server. Valid values are 'mysql',
'postgresql' and 'bind'. Defaults to 'mysql'.

##### `backend_install`

If you set this to true it will try to install a database backend for
you. This requires `db_root_password`. Defaults to true.

##### `backend_create_tables`

If set to true, it will ensure the required powerdns tables exist in your
backend database. If your database is on a separate host or you are using the
the Bind backend, set `backend_install` and `backend_create_tables` to false.
Defaults to true.

##### `db_root_password`

If you set `backend_install` to true you are asked to specify a root
password for your database.

##### `db_username`

Set the database username. Defaults to 'powerdns'.

##### `db_password`

Set the database password. Default is empty.

##### `db_name`

The database you want to use for PowerDNS. Defaults to 'powerdns'.

##### `db_host`

The host where your database should be created. Defaults to 'localhost'.

##### `db_port`

The port to use when connecting to your database. Defaults to '3306'. Only
supported in the MySQL backend currently.

##### `db_file`

The file where database will be stored when using SQLite backend. Defaults to '/var/lib/powerdns/powerdns.sqlite3'

##### `ldap_host`

The host where your LDAP server can be found. Defaults to 'ldap://localhost/'.

##### `ldap_basedn`

The path to search for in LDAP. Defaults to undef.

##### `ldap_method`

Defines how LDAP is queried. Defaults to 'strict'.

##### `ldap_binddn`

Path to the object to authenticate against. Defaults to undef.

##### `ldap_secret`

Password for simple authentication against ldap_basedn. Defaults to undef.

##### `custom_repo`

Don't manage the PowerDNS repo with this module. Defaults to false.

##### `custom_epel`

Don't manage the EPEL repo with this module. Defaults to false.

##### `version`

Set the PowerDNS version. Defaults to '4.1'.

##### `mysql_schema_file`

Set the PowerDNS MySQL schema file. Defaults to the location provided by
PowerDNS.

##### `pgsql_schema_file`

Set the PowerDNS PostgreSQL schema file. Defaults to the location provided by
PowerDNS.

#### powerdns::authoritative and powerdns::recursor

##### `package_ensure`

You can set the package version to be installed. Defaults to 'installed'.

### Defines

#### powerdns::config

All PowerDNS settings can be managed with `powerdns::config`. Depending on the
backend we will set a few configuration settings by default. All other
variables can be changed as follows:

```puppet
powerdns::config { 'api':
  ensure  => present,
  setting => 'api',
  value   => 'yes',
  type    => 'authoritative',
}
```

##### `setting`

The setting you want to change.

##### `value`

The value for the above setting.

##### `type`

The configuration file you want to change. Valid values are 'authoritative',
'recursor'. Defaults to 'authoritative'.

##### `ensure`

Specify whether or not this configuration should be present. Valid values are
'present', 'absent'. Defaults to 'present'.

### Hiera

This module supports Hiera and uses create_resources to configure PowerDNS
if you want to. An example can be found below:

```
powerdns::db_root_password: 's0m4r4nd0mp4ssw0rd'
powerdns::db_username: 'powerdns'
powerdns::db_password: 's0m4r4nd0mp4ssw0rd'
powerdns::recursor: true
powerdns::recursor::package_ensure: 'latest'
powerdns::authoritative::package_ensure: 'latest'

powerdns::auth::config:
  gmysql-dnssec:
    value: ''
  local-address:
    value: '127.0.0.1'
  api:
    value: 'yes'
```

#### Prevent duplicate declaration

In this example we configure `local-address` to `127.0.0.1`. If you also
run a recursor on the same server and you would like to configure
`local-address` via Hiera you need to set `setting` and change the name of
the parameter in Hiera to a unique value.

For example:

```
powerdns::auth::config:
  local-address-auth:
    setting: 'local-address'
    value: '127.0.0.1'
powerdns::recursor::config:
  local-address-recursor:
    setting: 'local-address'
    value: '127.0.0.2'
```

If you have other settings that share the same name between the recursor and
authoritative server you would have to use the same approach to prevent
duplicate declaration errors.

## Limitations

This module has been tested on:

* CentOS 6, 7
* Ubuntu 14.04, 16.04, 18.04
* Debian 8, 9
* Oracle Linux 7

We believe it also works on:

* Oracle Linux 6
* RedHat Enterprise Linux 6, 7
* Scientific Linux 6, 7

## Development

We strongly believe in the power of open source. This module is our way
of saying thanks.

This module is tested against the Ruby versions from Puppet's support
matrix. Please make sure you have a supported version of Ruby installed.

If you want to contribute please:

1. Fork the repository.
2. Run tests. It's always good to know that you can start with a clean slate.
3. Add a test for your change.
4. Make sure it passes.
5. Push to your fork and submit a pull request to the `develop` branch.

We can only accept pull requests with passing tests.

To install all of its dependencies please run:

```
bundle install --path vendor/bundle --without development
```

### Running unit tests

```
bundle exec rake test
```

### Running acceptance tests

The unit tests only verify if the code runs, not if it does exactly
what we want on a real machine. For this we use Beaker. Beaker will
start a new virtual machine (using Vagrant) and runs a series of
simple tests.

You can run Beaker tests with:

```
bundle exec rake spec_prep
BEAKER_destroy=onpass bundle exec rake beaker:centos6
BEAKER_destroy=onpass bundle exec rake beaker:centos7
BEAKER_destroy=onpass bundle exec rake beaker:oel7
BEAKER_destroy=onpass bundle exec rake beaker:ubuntu1404
BEAKER_destroy=onpass bundle exec rake beaker:ubuntu1604
BEAKER_destroy=onpass BEAKER_PUPPET_COLLECTION=puppet5 bundle exec rake beaker:ubuntu1804
BEAKER_destroy=onpass bundle exec rake beaker:debian8
BEAKER_destroy=onpass bundle exec rake beaker:debian9
```

We recommend specifying `BEAKER_destroy=onpass` as it will keep the
Vagrant machine running in case something fails.
