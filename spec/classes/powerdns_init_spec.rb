override_facts = {
  root_home: '/root'
}

require 'spec_helper'
describe 'powerdns', type: :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(override_facts)
        end

        case facts[:osfamily]
        when 'RedHat'
          authoritative_package_name = 'pdns'
          authoritative_service_name = 'pdns'
          authoritative_config = '/etc/pdns/pdns.conf'
          recursor_package_name = 'pdns-recursor'
          recursor_service_name = 'pdns-recursor'
        when 'Debian'
          authoritative_package_name = 'pdns-server'
          authoritative_service_name = 'pdns'
          authoritative_config = '/etc/powerdns/pdns.conf'
          recursor_package_name = 'pdns-recursor'
          recursor_service_name = 'pdns-recursor'
        end

        context 'powerdns class without parameters' do
          it 'fails' do
            expect { subject.call } .to raise_error(/'db_password' must be a non-empty string when 'authoritative' == true/)
          end
        end

        context 'powerdns class with parameters' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar'
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('powerdns::params') }

          # Check the repositories
          it { is_expected.to contain_class('powerdns::repo') }
          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_package('yum-plugin-priorities') }
            it { is_expected.to contain_yumrepo('powerdns') }
            it { is_expected.to contain_yumrepo('powerdns-recursor') }
          end
          case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_apt__key('powerdns') }
            it { is_expected.to contain_apt__pin('powerdns') }
            it { is_expected.to contain_apt__source('powerdns') }
            it { is_expected.to contain_apt__source('powerdns-recursor') }
          end

          # Check the authoritative server
          it { is_expected.to contain_class('powerdns::authoritative') }
          it { is_expected.to contain_package(authoritative_package_name).with('ensure' => 'installed') }
          it { is_expected.to contain_service(authoritative_service_name).with('ensure' => 'running') }
          it { is_expected.to contain_service(authoritative_service_name).with('enable' => 'true') }
          it { is_expected.to contain_service(authoritative_service_name).that_requires(format('Package[%<package>s]', package: authoritative_package_name)) }
        end

        context 'powerdns class with mysql backend' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              backend: 'mysql'
            }
          end

          it { is_expected.to contain_class('powerdns::backends::mysql') }
          it { is_expected.to contain_package('pdns-backend-mysql').with('ensure' => 'installed') }
          it { is_expected.to contain_mysql__db('powerdns').with('user' => 'foo', 'password' => 'bar', 'host' => 'localhost') }

          # We expect the following tables to be created
          it { is_expected.to contain_powerdns__backends__mysql__create_table('comments') }
          it { is_expected.to contain_powerdns__backends__mysql__create_table('cryptokeys') }
          it { is_expected.to contain_powerdns__backends__mysql__create_table('domainmetadata') }
          it { is_expected.to contain_powerdns__backends__mysql__create_table('domains') }
          it { is_expected.to contain_powerdns__backends__mysql__create_table('records') }
          it { is_expected.to contain_powerdns__backends__mysql__create_table('supermasters') }
          it { is_expected.to contain_powerdns__backends__mysql__create_table('tsigkeys') }

          # This creates additional resources
          it { is_expected.to contain_file('/tmp/create-table-comments') }
          it { is_expected.to contain_file('/tmp/create-table-cryptokeys') }
          it { is_expected.to contain_file('/tmp/create-table-domainmetadata') }
          it { is_expected.to contain_file('/tmp/create-table-domains') }
          it { is_expected.to contain_file('/tmp/create-table-records') }
          it { is_expected.to contain_file('/tmp/create-table-supermasters') }
          it { is_expected.to contain_file('/tmp/create-table-tsigkeys') }

          it { is_expected.to contain_exec('create-table-comments') }
          it { is_expected.to contain_exec('create-table-cryptokeys') }
          it { is_expected.to contain_exec('create-table-domainmetadata') }
          it { is_expected.to contain_exec('create-table-domains') }
          it { is_expected.to contain_exec('create-table-records') }
          it { is_expected.to contain_exec('create-table-supermasters') }
          it { is_expected.to contain_exec('create-table-tsigkeys') }

          # This sets our configuration
          it { is_expected.to contain_powerdns__config('gmysql-dbname').with('value' => 'powerdns') }
          it { is_expected.to contain_powerdns__config('gmysql-password').with('value' => 'bar') }
          it { is_expected.to contain_powerdns__config('gmysql-user').with('value' => 'foo') }
          it { is_expected.to contain_powerdns__config('launch').with('value' => 'gmysql') }

          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-dbname-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-password-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-user-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-launch-%<config>s', config: authoritative_config)) }
        end

        # Test the recursor
        context 'powerdns class with the recursor enabled and the authoritative server disabled' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              recursor: true,
              authoritative: false
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('powerdns::params') }

          # Check the authoritative server
          it { is_expected.to contain_class('powerdns::recursor') }
          it { is_expected.to contain_package(recursor_package_name).with('ensure' => 'installed') }
          it { is_expected.to contain_service(recursor_service_name).with('ensure' => 'running') }
          it { is_expected.to contain_service(recursor_service_name).with('enable' => 'true') }
          it { is_expected.to contain_service(recursor_service_name).that_requires(format('Package[%<package>s]', package: recursor_package_name)) }
        end

        # Test errors
        context 'powerdns class with an empty database username' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: '',
              db_password: 'bar'
            }
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/parameter 'db_username' expects a String\[1, default\] value, got String/)
          end
        end

        context 'powerdns class without database password' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo'
            }
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/'db_password' must be a non-empty string when 'authoritative' == true/)
          end
        end

        context 'powerdns class with an unsupported backend' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              backend: 'awesomedb'
            }
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/'backend' expects a match for Enum\['mysql'\]/)
          end
        end
      end
    end
  end
end
