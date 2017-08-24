# powerdns::config
define powerdns::config(
  $setting = $title,
  $value   = '',
  $ensure  = 'present',
  $type    = 'authoritative'
) {

  if $value == '' and ! ($setting in [ 'gmysql-dnssec', 'only-notify' ]) { fail("Value for ${setting} can't be empty.") }
  if $setting == 'gmysql-dnssec' { $line = $setting }
  else { $line = "${setting}=${value}" }

  case $type {
    'authoritative': {
      $path = $::powerdns::params::authoritative_config
      $require_package = $::powerdns::params::authoritative_package
      $notify_service = $::powerdns::params::authoritative_service
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

  file_line { "powerdns-config-${setting}-${path}":
    ensure  => $ensure,
    path    => $path,
    line    => $line,
    match   => "^${setting}=",
    require => Package[$require_package],
    notify  => Service[$notify_service],
    before  => Service[$notify_service],
  }
}
