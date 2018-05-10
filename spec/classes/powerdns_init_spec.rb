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
          pgsql_backend_package_name = 'pdns-backend-postgresql'
          pgsql_schema_file = '/usr/share/doc/pdns-backend-postgresql-4.?.?/schema.pgsql.sql'
          recursor_package_name = 'pdns-recursor'
          recursor_service_name = 'pdns-recursor'
        when 'Debian'
          authoritative_package_name = 'pdns-server'
          authoritative_service_name = 'pdns'
          authoritative_config = '/etc/powerdns/pdns.conf'
          pgsql_backend_package_name = 'pdns-backend-pgsql'
          pgsql_schema_file = '/usr/share/doc/pdns-backend-pgsql/schema.pgsql.sql'
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
            it { is_expected.to contain_yumrepo('powerdns').with('baseurl' => 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-41') }
            it { is_expected.to contain_yumrepo('powerdns-recursor') }
            it { is_expected.to contain_yumrepo('powerdns-recursor').with('baseurl' => 'http://repo.powerdns.com/centos/$basearch/$releasever/rec-41') }
          end
          case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_apt__key('powerdns') }
            it { is_expected.to contain_apt__pin('powerdns') }
            it { is_expected.to contain_apt__source('powerdns') }
            it { is_expected.to contain_apt__source('powerdns').with_release(/auth-41/) }
            it { is_expected.to contain_apt__source('powerdns-recursor') }
            it { is_expected.to contain_apt__source('powerdns-recursor').with_release(/rec-41/) }

            # On Ubuntu 17.04 and higher and Debian 9 and higher it expects dirmngr
            if facts[:operatingsystem] == 'Ubuntu'
              if facts[:operatingsystemmajrelease].to_i >= 17
                it { is_expected.to contain_package('dirmngr') }
              end
            end

            if facts[:operatingsystem] == 'Debian'
              if facts[:operatingsystemmajrelease].to_i >= 9
                it { is_expected.to contain_package('dirmngr') }
              end
            end
          end

          # Check the authoritative server
          it { is_expected.to contain_class('powerdns::authoritative') }
          it { is_expected.to contain_package(authoritative_package_name).with('ensure' => 'installed') }
          it { is_expected.to contain_service(authoritative_service_name).with('ensure' => 'running') }
          it { is_expected.to contain_service(authoritative_service_name).with('enable' => 'true') }
          it { is_expected.to contain_service(authoritative_service_name).that_requires(format('Package[%<package>s]', package: authoritative_package_name)) }
        end

        context 'powerdns class with different version' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              version: '4.0'
            }
          end
          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_yumrepo('powerdns').with('baseurl' => 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40') }
            it { is_expected.to contain_yumrepo('powerdns-recursor').with('baseurl' => 'http://repo.powerdns.com/centos/$basearch/$releasever/rec-40') }
          when 'Debian'
            it { is_expected.to contain_apt__source('powerdns').with_release(/auth-40/) }
            it { is_expected.to contain_apt__source('powerdns-recursor').with_release(/rec-40/) }
          end
        end

        context 'powerdns class with mysql backend' do
          let(:params) do
            {
              db_host: '127.0.0.1',
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              backend: 'mysql'
            }
          end

          it { is_expected.to contain_class('powerdns::backends::mysql') }
          it { is_expected.to contain_package('pdns-backend-mysql').with('ensure' => 'installed') }
          it { is_expected.to contain_mysql__db('powerdns').with('user' => 'foo', 'password' => 'bar', 'host' => '127.0.0.1') }
          it { is_expected.to contain_mysql__db('powerdns').with_sql(/4\.\?\.\?/) }

          # This sets our configuration
          it { is_expected.to contain_powerdns__config('gmysql-host').with('value' => '127.0.0.1') }
          it { is_expected.to contain_powerdns__config('gmysql-dbname').with('value' => 'powerdns') }
          it { is_expected.to contain_powerdns__config('gmysql-password').with('value' => 'bar') }
          it { is_expected.to contain_powerdns__config('gmysql-user').with('value' => 'foo') }
          it { is_expected.to contain_powerdns__config('launch').with('value' => 'gmysql') }

          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-host-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-dbname-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-password-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gmysql-user-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-launch-%<config>s', config: authoritative_config)) }
        end

        context 'powerdns class with postgresql backend' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              backend: 'postgresql'
            }
          end

          it { is_expected.to contain_class('powerdns::backends::postgresql') }
          it { is_expected.to contain_package(pgsql_backend_package_name).with('ensure' => 'installed') }
          it { is_expected.to contain_postgresql__server__db('powerdns').with('user' => 'foo') }
          it { is_expected.to contain_postgresql_psql('Load SQL schema').with('command' => format('\\i %<file>s', file: pgsql_schema_file)) }

          it { is_expected.to contain_powerdns__config('launch').with('value' => 'gpgsql') }
          it { is_expected.to contain_powerdns__config('gpgsql-host').with('value' => 'localhost') }
          it { is_expected.to contain_powerdns__config('gpgsql-dbname').with('value' => 'powerdns') }
          it { is_expected.to contain_powerdns__config('gpgsql-password').with('value' => 'bar') }
          it { is_expected.to contain_powerdns__config('gpgsql-user').with('value' => 'foo') }

          it { is_expected.to contain_file_line(format('powerdns-config-gpgsql-host-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gpgsql-dbname-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gpgsql-password-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-gpgsql-user-%<config>s', config: authoritative_config)) }
        end

        context 'powerdns class with bind backend' do
          let(:params) do
            {
              backend: 'bind'
            }
          end

          it { is_expected.to contain_class('powerdns::backends::bind') }
          it { is_expected.to contain_package('pdns-backend-bind').with('ensure' => 'installed') }

          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_file('/etc/pdns/named.conf').with('ensure' => 'file') }
            it { is_expected.to contain_file('/etc/pdns/named').with('ensure' => 'directory') }
            it { is_expected.to contain_powerdns__config('bind-config').with('value' => '/etc/pdns/named.conf') }
          end
          case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_file('/etc/powerdns/named.conf').with('ensure' => 'file') }
            it { is_expected.to contain_file('/etc/powerdns/named').with('ensure' => 'directory') }
            it { is_expected.to contain_powerdns__config('bind-config').with('value' => '/etc/powerdns/named.conf') }
          end

          it { is_expected.to contain_powerdns__config('launch').with('value' => 'bind') }

          it { is_expected.to contain_file_line(format('powerdns-config-bind-config-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-config-launch-%<config>s', config: authoritative_config)) }
          it { is_expected.to contain_file_line(format('powerdns-bind-baseconfig')) }
        end

        context 'powerdns class with backend_create_tables set to false' do
          let(:params) do
            {
              db_root_password: 'foobar',
              db_username: 'foo',
              db_password: 'bar',
              backend: 'mysql',
              backend_create_tables: false
            }
          end

          # Tables aren't created and neither is the database
          it { is_expected.not_to contain_mysql__db('powerdns').with('user' => 'foo', 'password' => 'bar', 'host' => 'localhost') }

          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('comments') }
          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('cryptokeys') }
          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('domainmetadata') }
          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('domains') }
          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('records') }
          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('supermasters') }
          it { is_expected.not_to contain_powerdns__backends__mysql__create_table('tsigkeys') }
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
            expect { subject.call } .to raise_error(/parameter 'db_username' expects a (value of type Undef or )?String\[1, default\]( value)?, got String/)
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
            expect { subject.call } .to raise_error(/'backend' expects a match for Enum\['bind', 'mysql', 'postgresql'\]/)
          end
        end
      end
    end
  end
end
