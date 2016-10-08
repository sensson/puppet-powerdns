require 'spec_helper_acceptance'

describe 'powerdns class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'powerdns':
        db_password => 's0m4r4nd0mp4ssw0rd',
        db_root_password => 'v3rys3c4r3',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    #describe package('powerdns') do
    #  it { is_expected.to be_installed }
    #end

    #describe service('powerdns') do
    #  it { is_expected.to be_enabled }
    #  it { is_expected.to be_running }
    #end
  end
end