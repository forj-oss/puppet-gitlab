source :rubygems
puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : '>= 2.7'

gem 'rake'

group :development do
  gem 'better_errors'
  gem 'puppet', puppetversion
end

group :test do
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'rspec-hiera-puppet'
  gem 'puppet-lint'
  gem 'ci_reporter'
  gem 'puppetlabs_spec_helper'
end
