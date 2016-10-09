# powerdns::repo
class powerdns::repo {
  case $::operatingsystem {
    'centos': {
      Yumrepo['powerdns'] -> Package <| title == $::powerdns::params::authorative_package |>
      Yumrepo['powerdns-recursor'] -> Package <| title == $::powerdns::params::recursor_package |>

      package { 'yum-plugin-priorities':
        ensure => installed,
        before => Yumrepo['powerdns'],
      }

      yumrepo { 'powerdns':
        name        => 'powerdns',
        descr       => 'PowerDNS repository for PowerDNS Authorative - version 4.0.X',
        baseurl     => 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40',
        gpgkey      => 'https://repo.powerdns.com/FD380FBB-pub.asc',
        gpgcheck    => 1,
        enabled     => 1,
        priority    => 90,
        includepkgs => 'pdns*',
      }

      yumrepo { 'powerdns-recursor':
        name        => 'powerdns-recursor',
        descr       => 'PowerDNS repository for PowerDNS Recursor - version 4.0.X',
        baseurl     => 'http://repo.powerdns.com/centos/$basearch/$releasever/rec-40',
        gpgkey      => 'https://repo.powerdns.com/FD380FBB-pub.asc',
        gpgcheck    => 1,
        enabled     => 1,
        priority    => 90,
        includepkgs => 'pdns*',
      }
    }

    'ubuntu': {
      include ::apt

      # Make sure the repo's are added before we're managing packages
      # puppet-lint seems to error out on spaces here (bug?) so it looks a bit dodgy
      Class['apt::update']->Package<||>

      apt::key { 'powerdns':
        ensure => present,
        id     => 'FD380FBB',
        source => 'https://repo.powerdns.com/FD380FBB-pub.asc',
      }

      apt::source { 'powerdns':
        ensure       => present,
        location     => 'http://repo.powerdns.com/ubuntu',
        repos        => 'main',
        release      => 'trusty-auth-40',
        architecture => 'amd64',
        require      => Apt::Key['powerdns'],
      }

      apt::source { 'powerdns-recursor':
        ensure       => present,
        location     => 'http://repo.powerdns.com/ubuntu',
        repos        => 'main',
        release      => 'trusty-rec-40',
        architecture => 'amd64',
        require      => Apt::Key['powerdns'],
      }

      apt::pin { 'powerdns':
        priority => 600,
        packages => 'pdns-*',
        origin   => 'repo.powerdns.com',
        require  => Apt::Source['powerdns'],
      }
    }

    default: {
      fail("${::operatingsystem} is not supported yet.")
    }
  }
}