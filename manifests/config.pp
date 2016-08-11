# powerdns::config
define powerdns::config($setting = $title, $value = '', $ensure = 'present', $type = 'authorative') {
  if $value == '' and $setting != 'gmysql-dnssec' { fail("Value can't be empty.") }
  if $setting == 'gmysql-dnssec' { $line = $setting }
  else { $line = "${setting}=${value}" }

  case $type {
    'authorative': {
      $path = '/etc/pdns/pdns.conf'
      $require = 'pdns'
    }
    'recursor': {
      $path = '/etc/pdns-recursor/recursor.conf'
      $require = 'pdns-recursor'
    }

    default: {
      fail("$type is not supported as config type.")
    }
  }

  file_line { "powerdns-config-${setting}-${value}-${path}":
    path => $path,
    line => $line,
    match => "^${setting}=",
    require => Package[$require],
    notify => Service[$require],
    ensure => $ensure,
  }
}

