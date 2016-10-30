require 'spec_helper_acceptance'

describe 'powerdns class' do
  context 'authoritative server' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
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
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  end

  context 'recursor server' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'powerdns':
        authoritative => false,
        recursor => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  end
end
