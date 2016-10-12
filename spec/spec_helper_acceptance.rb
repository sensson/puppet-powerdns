require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  fixture_modules = File.join(proj_root, 'spec', 'fixtures', 'modules')

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # This is our workaround for Ubuntu 16.04 servers
      if host['platform'] == 'ubuntu-1604-amd64'
        unless ENV['BEAKER_provision'] == 'no'
          # Install the repo and the puppet agent package
          on host, 'wget -O /tmp/puppetlabs-release-pc1-xenial.deb https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb'
          on host, 'dpkg -i /tmp/puppetlabs-release-pc1-xenial.deb'
          on host, 'apt-get update'
          install_package(host, 'puppet-agent')
          
          # Sorry, it's a symlink
          on host, 'ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet'
          on host, 'puppet --version'

          # Override the module directory as this is required for Puppet 4
          on host, 'mkdir -p /etc/puppet/modules'
          on host, 'rm -rf /opt/puppetlabs/puppet/modules'
          on host, 'ln -s /etc/puppet/modules/ /opt/puppetlabs/puppet/modules'
        end
      else
        run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
      end

      install_package(host, 'rsync')
      rsync_to(host, fixture_modules, '/etc/puppet/modules/')
    end

    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'powerdns')
  end
end