# frozen_string_literal: true

require 'spec_helper_acceptance'

case default['platform']
when %r{debian|ubuntu}
  authoritative_config = '/etc/powerdns/pdns.conf'
when %r{el|centos}
  authoritative_config = '/etc/pdns/pdns.conf'
else
  logger.notify("Cannot manage PowerDNS on #{default['platform']}")
end

describe 'powerdns class' do
  context 'authoritative server' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
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
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'gmysql-host=localhost' }
    end

    describe service('pdns') do
      it { is_expected.to be_running }
    end

    describe command('/usr/bin/pdns_control version') do
      its(:stdout) { is_expected.to match %r{^4\.9} }
    end
  end

  context 'recursor server' do
    it 'works idempotently with no errors' do
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
