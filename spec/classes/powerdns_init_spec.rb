require 'spec_helper'
describe 'powerdns', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts

          facts.merge({
            :root_home => '/root',
          })
        end

        context "powerdns class without parameters" do
          it 'fails' do
            expect { subject.call } .to raise_error(/Database root password can't be empty/)
          end
        end

        context "powerdns class with parameters" do
          let(:params) {{ 
            :db_root_password => 'foobar',
            :db_username => 'foo',
            :db_password => 'bar'
          }}

          it { is_expected.to compile.with_all_deps }

          # Check the repositories
          it { is_expected.to contain_class('powerdns::repo') }
          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_yumrepo('powerdns') }
            it { is_expected.to contain_yumrepo('powerdns').that_comes_before('Package[pdns]') }
            it { is_expected.to contain_yumrepo('powerdns').that_comes_before('Package[pdns-recursor]') }
          end

          # Check the authorative server
          it { is_expected.to contain_class('powerdns::authorative') }
          it { is_expected.to contain_package('pdns').with('ensure' => 'installed') }
          it { is_expected.to contain_service('pdns').with('ensure' => 'running') }
          it { is_expected.to contain_service('pdns').that_requires('Package[pdns]') }

          # Check the recursor
          it { is_expected.to contain_class('powerdns::recursor') }
          it { is_expected.to contain_package('pdns-recursor').with('ensure' => 'absent') }
          it { is_expected.to contain_service('pdns-recursor').with('ensure' => 'stopped') }
          it { is_expected.to contain_service('pdns-recursor').that_requires('Package[pdns-recursor]') }
        end

        context "powerdns class with mysql backend" do
          let(:params) {{ 
            :db_root_password => 'foobar',
            :db_username => 'foo',
            :db_password => 'bar',
            :backend => 'mysql'
          }}

          it { is_expected.to contain_package('pdns-backend-mysql').with('ensure' => 'installed') }
          it { is_expected.to contain_mysql__db('powerdns').with(
              'user' => 'foo',
              'password' => 'bar',
              'host' => 'localhost'
            ) }
        end

        context "powerdns class with an empty database username" do
          let(:params) {{ 
            :db_root_password => 'foobar',
            :db_username => '',
            :db_password => 'bar'
          }}
          
          it 'fails' do
            expect { subject.call } .to raise_error(/Database username can't be empty/)
          end
        end

        context "powerdns class without database password" do
          let(:params) {{ 
            :db_root_password => 'foobar',
            :db_username => 'foo'
          }}
          
          it 'fails' do
            expect { subject.call } .to raise_error(/Database password can't be empty/)
          end
        end

        context "powerdns class with an unsupported backend" do
          let(:params) {{ 
            :db_root_password => 'foobar',
            :db_username => 'foo',
            :db_password => 'bar',
            :backend => 'awesomedb'
          }}
          
          it 'fails' do
            expect { subject.call } .to raise_error(/is not supported/)
          end
        end
      end
    end 
  end
end