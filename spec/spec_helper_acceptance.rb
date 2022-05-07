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
      run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no' # rubocop:disable Style/FetchEnvVar

      # Install rsync
      install_package(host, 'rsync')

      # A workaround -- this is required for backwards compatibility
      on host, 'mkdir -p /etc/puppet/modules/'
      on host, 'mkdir -p /etc/puppetlabs/code/'
      on host, 'rm -rf /etc/puppetlabs/code/modules'
      on host, 'ln -s /etc/puppet/modules/ /etc/puppetlabs/code/'

      # A workaround for systemd-resolved on Ubuntu 18.04. Thanks, systemd.
      if host['platform'] == 'ubuntu-1804-amd64'
        on host, 'systemctl stop systemd-resolved'
        on host, 'echo "nameserver 1.1.1.1" > /etc/resolv.conf'
      end

      # Sorry, it's a symlink, PATH doesn't work
      on host, 'ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet'
      on host, 'puppet --version'

      # Synchronise modules
      rsync_to(host, fixture_modules, '/etc/puppet/modules/')
    end

    # Install module and dependencies
    puppet_module_install(source: proj_root, module_name: 'powerdns')
  end
end
