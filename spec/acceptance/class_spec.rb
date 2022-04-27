require 'spec_helper_acceptance'

case default['platform']
when /debian|ubuntu/
  authoritative_config = '/etc/powerdns/pdns.conf'
when /el|centos/
  authoritative_config = '/etc/pdns/pdns.conf'
else
  logger.notify("Cannot manage PowerDNS on #{default['platform']}")
end

describe 'powerdns class' do
  context 'authoritative server' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-PUPPET
      class { 'powerdns':
        db_password => 's0m4r4nd0mp4ssw0rd',
        db_root_password => 'v3rys3c4r3',
      }

      # This makes sure the second test can run successfully
      # on Debian-based systems. Debian has the odd tendency
      # to start services before they are configured.
      powerdns::config { 'authoritative-local-port':
        type => 'authoritative',
        setting => 'local-port',
        value => 54,
      }
      PUPPET

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file(authoritative_config) do
      it { should be_file }
      its(:content) { should match 'gmysql-host=localhost' }
    end

    describe service('pdns') do
      it { should be_running }
    end

    describe command('/usr/bin/pdns_control version') do
      its(:stdout) { should match '4.1' }
    end
  end

  context 'recursor server' do
    it 'should work idempotently with no errors' do
      pp = <<-PUPPET
      class { 'powerdns':
        authoritative => false,
        recursor => true,
      }
      PUPPET

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
