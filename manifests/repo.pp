# powerdns::repo
class powerdns::repo {
  case $::operatingsystem {
    'centos': {
      package { 'yum-plugin-priorities':
        ensure => installed,
        before => Yumrepo['powerdns'],
      }

      yumrepo { 'powerdns':
        name        => 'powerdns',
        descr       => 'PowerDNS repository for PowerDNS Recursor - version 4.0.X',
        baseurl     => 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40',
        gpgkey      => 'https://repo.powerdns.com/FD380FBB-pub.asc',
        gpgcheck    => 1,
        enabled     => 1,
        priority    => 90,
        includepkgs => 'pdns*',
        before      => [ Package['pdns'], Package['pdns-recursor'] ],
      }
    }

    default: {
      fail("${::operatingsystem} is not supported yet.")
    }
  }
}