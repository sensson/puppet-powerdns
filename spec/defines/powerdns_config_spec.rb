override_facts = {
  root_home: '/root'
}

require 'spec_helper'
describe 'powerdns::config' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(override_facts)
        end

        let :title do
          'foo'
        end

        let(:pre_condition) do
          'class { "::powerdns":
            db_root_password => "foobar",
            db_username => "foo",
            db_password => "bar",
            recursor => true,
          }'
        end

        case facts[:osfamily]
        when 'RedHat'
          authoritative_config = '/etc/pdns/pdns.conf'
          recursor_config = '/etc/pdns-recursor/recursor.conf'
        when 'Debian'
          authoritative_config = '/etc/powerdns/pdns.conf'
          recursor_config = '/etc/powerdns/recursor.conf'
        end

        context 'powerdns::config with parameters' do
          let(:params) do
            {
              setting: 'foo',
              value: 'bar'
            }
          end

          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)).with_ensure('present') }
          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)).with_path(authoritative_config) }
          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)).with_line('foo=bar') }
          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)).with_match('^foo=') }
          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)).with_match_for_absence(true) }
          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)).that_notifies('Service[pdns]') }
        end

        context 'powerdns::config with recursor type' do
          let(:params) do
            {
              setting: 'foo',
              value: 'bar',
              type: 'recursor'
            }
          end

          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: recursor_config)) }
        end

        context 'powerdns::config with integers' do
          let(:params) do
            {
              setting: 'local-port',
              value: 54
            }
          end

          it { is_expected.to contain_file_line(format('powerdns-config-local-port-%<config>s', config: authoritative_config)) }
        end

        # Test for empty values
        context 'powerdns::config with empty value for gmysql-dnssec' do
          let(:params) do
            {
              setting: 'gmysql-dnssec'
            }
          end

          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-dnssec-%<config>s', config: authoritative_config)) }
        end

        context 'powerdns::config with empty value for only-notify' do
          let(:params) do
            {
              setting: 'only-notify'
            }
          end

          it { is_expected.to contain_file_line(format('powerdns-config-only-notify-%<config>s', config: authoritative_config)) }
        end

        context 'powerdns::config with empty value' do
          let(:params) do
            {
              setting: 'empty'
            }
          end

          it 'fails' do
            expect { subject.call }.to raise_error(/Value for empty can't be empty./)
          end
        end

        context 'powerdns::config with empty value and ensure == absent' do
          let(:params) do
            {
              ensure: 'absent',
              setting: 'foo'
            }
          end

          it { is_expected.to contain_file_line(format('powerdns-config-foo-%<config>s', config: authoritative_config)) }
        end

        # Test incorrect service type
        context 'powerdns::config with wrong type' do
          let(:params) do
            {
              setting: 'foo',
              value: 'bar',
              type: 'something'
            }
          end

          it 'fails' do
            expect { subject.call }.to raise_error(/expects a match for Enum\['authoritative', 'recursor'\], got/)
          end
        end
      end
    end
  end
end
