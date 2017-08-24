require 'spec_helper'
describe 'powerdns::config' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts

          facts.merge({
            :root_home => '/root',
          })
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
          authoritative_package_name = 'pdns'
          authoritative_service_name = 'pdns'
          authoritative_config = '/etc/pdns/pdns.conf'
          recursor_package_name = 'pdns-recursor'
          recursor_service_name = 'pdns-recursor'
          recursor_config = '/etc/pdns-recursor/recursor.conf'
        when 'Debian'
          authoritative_package_name = 'pdns-server'
          authoritative_service_name = 'pdns'
          authoritative_config = '/etc/powerdns/pdns.conf'
          recursor_package_name = 'pdns-recursor'
          recursor_service_name = 'pdns-recursor'
          recursor_config = '/etc/powerdns/recursor.conf'
        end

        # 
        context 'powerdns::config with parameters' do
          let(:params) do
            {
              setting: 'foo',
              value: 'bar'
            }
          end

          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ authoritative_config ]) }
          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ authoritative_config ]).with_ensure('present') }
          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ authoritative_config ]).with_path(authoritative_config) }
          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ authoritative_config ]).with_line('foo=bar') }
          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ authoritative_config ]).with_match('^foo=') }
          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ authoritative_config ]).that_notifies('Service[%s]' % authoritative_service_name) }
        end

        context 'powerdns::config with recursor type' do
          let(:params) do
            {
              setting: 'foo',
              value: 'bar',
              type: 'recursor'
            }
          end

          it { is_expected.to contain_file_line('powerdns-config-foo-%s' % [ recursor_config ]) }
        end

        # Test for empty values
        context 'powerdns::config with empty value for gmysql-dnssec' do
          let(:params) do
            {
              setting: 'gmysql-dnssec',
            }
          end

          it { is_expected.to contain_file_line('powerdns-config-gmysql-dnssec-%s' % [ authoritative_config ]) }
        end

        context 'powerdns::config with empty value for only-notify' do
          let(:params) do
            {
              setting: 'only-notify',
            }
          end

          it { is_expected.to contain_file_line('powerdns-config-only-notify-%s' % [ authoritative_config ]) }
        end

        context 'powerdns::config with empty value' do
          let(:params) do
            {
              setting: 'empty',
            }
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/Value for empty can't be empty./)
          end
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
            expect { subject.call } .to raise_error(/is not supported as config type/)
          end
        end
      end
    end
  end
end
