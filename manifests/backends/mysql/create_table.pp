# powerdns::backends::mysql::create_table
# This is a very straight forward function that checks if the table is available
# and if it isn't it will create one for you based on the content from $create
# 
# $create can be plain text or a template. We prefer templates.
#
define powerdns::backends::mysql::create_table($database = '', $table = $title, $create = '') {
    if $database == '' { fail("No database specified for ${table}.") }
    if $create == '' { fail("No create statement specified for ${table}.") }

    # create a file containing our create table statement
    file { "/tmp/create-table-${table}":
      ensure  => present,
      content => $create,
    }

    # create our table
    exec { "create-table-${table}":
      logoutput => true,
      command   => "/usr/bin/mysql --defaults-file=${::mysql::root_home}/.my.cnf ${database} < /tmp/create-table-${table}",
      unless    => "/usr/bin/mysql --defaults-file=${::mysql::root_home}/.my.cnf -e 'desc ${database}.${table}' > /dev/null 2>&1",
      subscribe => Service['mysqld'],
      require   => [
        Service['mysqld'],
        Package['mysql-server'],
        File["${::mysql::root_home}/.my.cnf"],
        File["/tmp/create-table-${table}"],
        Mysql::Db[$database]
      ],
    }
  }