# powerdns::config
define powerdns::config(
  $setting = $title,
  $value   = '',
  $ensure  = 'present',
  $type    = 'authorative'
) {

  if $value == '' and $setting != 'gmysql-dnssec' { fail("Value can't be empty.") }
  if $setting == 'gmysql-dnssec' { $line = $setting }
  else { $line = "${setting}=${value}" }

  case $type {
    'authorative': {
      $path = $::powerdns::params::authorative_config
      $require_package = $::powerdns::params::authorative_package
      $notify_service = $::powerdns::params::authorative_service
    }
    'recursor': {
      $path = $::powerdns::params::recursor_config
      $require_package = $::powerdns::params::recursor_package
      $notify_service = $::powerdns::params::recursor_service
    }

    default: {
      fail("${type} is not supported as config type.")
    }
  }

  file_line { "powerdns-config-${setting}-${value}-${path}":
    ensure  => $ensure,
    path    => $path,
    line    => $line,
    match   => "^${setting}=",
    require => Package[$require_package],
    notify  => Service[$notify_service],
    before  => Service[$notify_service],
  }
}

