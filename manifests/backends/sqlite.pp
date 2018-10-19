# sqlite backend for powerdns
class powerdns::backends::sqlite inherits powerdns {
  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'gslite3',
    type    => 'authoritative',
  }

  powerdns::config { 'gsqlite3-database':
    ensure  => present,
    setting => 'gsqlite3-database',
    value   => $::powerdns::db_file,
    type    => 'authoritative',
  }
}
