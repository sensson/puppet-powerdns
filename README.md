# PowerDNS 

[![Build Status](https://travis-ci.org/sensson/puppet-powerdns.svg?branch=master)](https://travis-ci.org/sensson/puppet-powerdns)

This module can be used to configure both the recursor and authorative 
PowerDNS 4.x server. We don't support version 2.x or 3.x.

## Examples

### Installation and configuration

This will install the authorative PowerDNS server which includes the
MySQL server and the management of the database and its tables.

```
class { 'powerdns':
	db_password => 's0m4r4nd0mp4ssw0rd',
	db_root_password => 'v3rys3c4r3',
	backend_install => true,
}
```

## Reference

### Parameters

#### powerdns

We provide a number of configuration options to change particular settings
or to override our defaults when required.

##### `authorative`

Install the PowerDNS authorative server. Defaults to true.

##### `recursor`

Install the PowerDNS recursor. Defaults to false.

##### `backend`

Choose a backend for the authorative server. Valid values are 'mysql'. Defaults to 'mysql'.

##### `backend_install`

If you set this to true it will try to install a database backend for
you. This requires `db_root_password`, `db_username`, `db_password`,
`db_name` and `db_host` to be set. Defaults to true.

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

### Defines

#### powerdns::config

All PowerDNS settings can be managed with `powerdns::config`.

```
powerdns::config { 'launch':
	ensure => present,
	setting => 'launch',
	value => 'gmysql',
	type => 'authorative',
}
```

##### `setting`

The setting you want to change.

##### `value`

The value for the above setting.

##### `type`

The configuration file you want to change. Valid values are 'authorative', 'recursor'. Defaults to 'authorative'.

##### `ensure`

Specify whether or not this configuration should be present. Valid values are 'present', 'absent'. Defaults to 'present'.

### Hiera

This module supports Hiera and uses create_resources to configure PowerDNS
if you want to. An example can be found below:

```
powerdns::db_root_password: 's0m4r4nd0mp4ssw0rd'
powerdns::db_username: 'powerdns'
powerdns::db_password: 's0m4r4nd0mp4ssw0rd'
powerdns::recursor: true

powerdns::auth::config:
  launch:
    value: 'gmysql'
  gmysql-dnssec:
    value: ''
  gmysql-user: 
    value: "%{hiera('powerdns::db_username')}"
  gmysql-password:
    value: "%{hiera('powerdns::db_password')}"
  gmysql-dbname:
    value: 'powerdns'
  gmysql-supermaster-query:
    value: "select account from supermasters where ip=\'%s\'"
```

## Limitations

This module has been tested on:

* CentOS 7