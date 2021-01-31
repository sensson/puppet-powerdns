# powerdns::repo
class powerdns::repo inherits powerdns {

  # The repositories of PowerDNS use a version such as '40' for version 4.0
  # and 41 for version 4.1.
  $short_version = regsubst($::powerdns::version, /^(\d)\.(\d)$/, '\\1\\2', 'G')

  case $facts['os']['family'] {
    'RedHat': {
      unless $::powerdns::custom_epel {
        include ::epel
      }

      Yumrepo['powerdns'] -> Package <| title == $::powerdns::params::authoritative_package |>
      Yumrepo['powerdns-recursor'] -> Package <| title == $::powerdns::params::recursor_package |>

      if versioncmp($::operatingsystemmajrelease, '7') <= 0 {
        ensure_packages('yum-plugin-priorities', {ensure => installed, before => Yumrepo['powerdns']})
      }

      if versioncmp($::operatingsystemmajrelease, '8') >= 0 {
        yumrepo { 'powertools':
          ensure     => 'present',
          descr      => 'PowerTools',
          mirrorlist => "http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=PowerTools&infra=\$infra",
          enabled    => 'true',
          gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
          gpgcheck   => 'true',
        }
      }

      yumrepo { 'powerdns':
        name        => 'powerdns',
        descr       => "PowerDNS repository for PowerDNS Authoritative - version ${::powerdns::version}",
        baseurl     => "http://repo.powerdns.com/centos/\$basearch/\$releasever/auth-${short_version}",
        gpgkey      => 'https://repo.powerdns.com/FD380FBB-pub.asc',
        gpgcheck    => 1,
        enabled     => 1,
        priority    => 90,
        includepkgs => 'pdns*',
      }

      yumrepo { 'powerdns-recursor':
        name        => 'powerdns-recursor',
        descr       => "PowerDNS repository for PowerDNS Recursor - version ${::powerdns::version}",
        baseurl     => "http://repo.powerdns.com/centos/\$basearch/\$releasever/rec-${short_version}",
        gpgkey      => 'https://repo.powerdns.com/FD380FBB-pub.asc',
        gpgcheck    => 1,
        enabled     => 1,
        priority    => 90,
        includepkgs => 'pdns*',
      }
    }

    'Debian': {
      include ::apt

      $os = downcase($facts['os']['name'])

      apt::key { 'powerdns':
        ensure => present,
        id     => '9FAAA5577E8FCF62093D036C1B0C6205FD380FBB',
        source => 'https://repo.powerdns.com/FD380FBB-pub.asc',
      }

      apt::source { 'powerdns':
        ensure       => present,
        location     => "http://repo.powerdns.com/${os}",
        repos        => 'main',
        release      => "${::lsbdistcodename}-auth-${short_version}",
        architecture => 'amd64',
        require      => Apt::Key['powerdns'],
      }

      apt::source { 'powerdns-recursor':
        ensure       => present,
        location     => "http://repo.powerdns.com/${os}",
        repos        => 'main',
        release      => "${::lsbdistcodename}-rec-${short_version}",
        architecture => 'amd64',
        require      => Apt::Source['powerdns'],
      }

      apt::pin { 'powerdns':
        priority => 600,
        packages => 'pdns-*',
        origin   => 'repo.powerdns.com',
        require  => Apt::Source['powerdns-recursor'],
      }

      Apt::Pin['powerdns'] -> Package <| title == $::powerdns::params::authoritative_package |>
      Apt::Pin['powerdns'] -> Package <| title == $::powerdns::params::recursor_package |>
    }

    'FreeBSD': {
      # Use the official pkg repository
    }

    default: {
      fail("${facts['os']['family']} is not supported yet.")
    }
  }
}
