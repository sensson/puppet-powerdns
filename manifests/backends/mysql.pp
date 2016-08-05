# mysql backend for powerdns
class powerdns::backends::mysql inherits powerdns {
  if $db_name == '' { fail("No database name specified.") }
  if $db_username == '' { fail("No database username specified.") }
  if $db_password == '' { fail("No database password specified.") }

  # This is a very straight forward function that checks if the table is available
  # and if it isn't it will create one for you.
  define create_table($database = '', $table = $title, $create = '') {
    if $database == '' { fail("No database specified for $table.") }
    if $create == '' { fail("No create statement specified for $table.") }

    # create a file containing our create table statement
    file { "/tmp/create-table-${table}":
      ensure => present,
      content => $create,
    }

    # create our table
    exec { "create-table-${table}":
      logoutput => true,
      command => "mysql --defaults-file=/root/.my.cnf $database < /tmp/create-table-$table",
      unless => "mysql --defaults-file=/root/.my.cnf -e 'desc $database.$table' > /dev/null 2>&1",
      subscribe => Service[$mysql::params::server_service_name],
      require => [ 
        Service[$mysql::params::server_service_name], 
        Package[$mysql::params::server_package_name], 
        File['/root/.my.cnf'], 
        File["/tmp/create-table-$table"],
        Mysql::Db[$database] 
      ],
    }
  }

  # set up the powerdns backend
  package { 'pdns-backend-mysql':
    ensure => $authorative_install,
    before => Service['pdns'],
    require => Package['pdns'],
  }

  if $backend_install == true {
    if $db_root_password == '' { fail("No database root password specified.") }
    # mysql database
    if ! defined(Class['::mysql::server']) {
      class { '::mysql::server': 
        root_password => $db_root_password,
      }
    }

    if ! defined(Class['::mysql::server::account_security']) {
      class { '::mysql::server::account_security': }
    }
  }

  # make sure the database exists
  mysql::db { $db_name:
    user => $db_username,
    password => $db_password,
    host => $db_host,
    grant => [ 'ALL' ],
  }

  # create tables
  powerdns::backends::mysql::create_table { 'domains':
    database => $db_name,
    create => template('powerdns/domains.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'records':
    database => $db_name,
    create => template('powerdns/records.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'supermasters':
    database => $db_name,
    create => template('powerdns/supermasters.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'domainmetadata':
    database => $db_name,
    create => template('powerdns/domainmetadata.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'cryptokeys':
    database => $db_name,
    create => template('powerdns/cryptokeys.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'comments':
    database => $db_name,
    create => template('powerdns/comments.sql.erb'),
  }

  powerdns::backends::mysql::create_table { 'tsigkeys':
    database => $db_name,
    create => template('powerdns/tsigkeys.sql.erb'),
  }
}