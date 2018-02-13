source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['~> 4.7.0']
gem 'facter', '>= 1.7.0'
gem 'metadata-json-lint', '< 2.0.0'
gem 'puppet', puppetversion
gem 'puppet-lint', '>= 1.0.0'
gem 'puppetlabs_spec_helper', '>= 1.0.0'
gem 'rspec-puppet', '~> 2.6.0'
gem 'rspec-puppet-facts', '~> 1.9.0'
gem 'rubocop', '>= 0.48.1'
gem 'safe_yaml', '~> 1.0.4'
gem 'simplecov', require: false
gem 'simplecov-console', require: false

group :system_tests do
  gem 'beaker', '<= 2.51.0' if RUBY_VERSION < '2.2.5'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-rspec'
  gem 'nokogiri', '< 1.7.0' if RUBY_VERSION < '2.1.0'
  gem 'public_suffix', '<= 1.4.6' if RUBY_VERSION < '2.0.0'
end
