require 'spec_helper'
describe 'powerdns', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "powerdns class with parameters" do
          let(:params) {{ 
            :db_root_password => 'foobar',
            :db_username => 'foo',
            :db_password => 'bar'
          }}
          it { is_expected.to compile.with_all_deps }
        end
      end
    end 
  end
end