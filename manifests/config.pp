# powerdns::config
define powerdns::config(
  String                            $setting = $title,
  Variant[String, Integer]          $value   = '',
  Enum['present', 'absent']         $ensure  = 'present',
  Enum['authoritative', 'recursor'] $type    = 'authoritative'
) {

  unless $ensure == 'absent' or ($setting in [ 'gmysql-dnssec', 'only-notify', 'allow-notify-from' ]) {
    assert_type(Variant[String[1], Integer], $value) |$_expected, $_actual| {
      fail("Value for ${setting} can't be empty.")
    }
  }

  if $setting == 'gmysql-dnssec' { $line = $setting }
  else { $line = "${setting}=${value}" }

  if $type == 'authoritative' {
    $path            = $::powerdns::params::authoritative_config
    $require_package = $::powerdns::params::authoritative_package
    $notify_service  = $::powerdns::params::authoritative_service
  } else {
    $path            = $::powerdns::params::recursor_config
    $require_package = $::powerdns::params::recursor_package
    $notify_service  = $::powerdns::params::recursor_service
  }

  file_line { "powerdns-config-${setting}-${path}":
    ensure            => $ensure,
    path              => $path,
    line              => $line,
    match             => "^${setting}=",
    match_for_absence => true, # ignored when ensure == 'present'
    require           => Package[$require_package],
    notify            => Service[$notify_service],
  }
}
