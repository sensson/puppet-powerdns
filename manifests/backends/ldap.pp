# ldap backend for powerdns
class powerdns::backends::ldap ($package_ensure = $powerdns::params::default_package_ensure) inherits powerdns {
  if $facts['os']['family'] == 'Debian' {
    # The pdns-server package from the Debian APT repo automatically installs the bind
    # backend package which we do not want when using another backend such as ldap.
    package { 'pdns-backend-bind':
      ensure  => purged,
      require => Package[$powerdns::params::authoritative_package],
    }
  }

  # set the configuration variables
  powerdns::config { 'launch':
    ensure  => present,
    setting => 'launch',
    value   => 'ldap',
    type    => 'authoritative',
  }

  powerdns::config { 'ldap-host':
    ensure  => present,
    setting => 'ldap-host',
    value   => $powerdns::ldap_host,
    type    => 'authoritative',
  }

  powerdns::config { 'ldap-binddn':
    ensure  => present,
    setting => 'ldap-binddn',
    value   => $powerdns::ldap_binddn,
    type    => 'authoritative',
  }

  $_ldap_secret = $powerdns::ldap_secret =~ Sensitive ? {
    true => $powerdns::ldap_secret.unwrap,
    false => $powerdns::ldap_secret
  }

  powerdns::config { 'ldap-secret':
    ensure  => present,
    setting => 'ldap-secret',
    value   => $_ldap_secret,
    type    => 'authoritative',
  }

  powerdns::config { 'ldap-basedn':
    ensure  => present,
    setting => 'ldap-basedn',
    value   => $powerdns::ldap_basedn,
    type    => 'authoritative',
  }

  powerdns::config { 'ldap-method':
    ensure  => present,
    setting => 'ldap-method',
    value   => $powerdns::ldap_method,
    type    => 'authoritative',
  }

  if $powerdns::params::ldap_backend_package_name {
    # set up the powerdns backend
    package { $powerdns::params::ldap_backend_package_name:
      ensure  => $package_ensure,
      before  => Service['pdns'],
      require => Package[$powerdns::params::authoritative_package],
    }
  }

  if $powerdns::backend_install {
    fail('backend_install is not supported with ldap')
  }

  if $powerdns::backend_create_tables {
    fail('backend_create_tables is not supported with ldap')
  }
}
