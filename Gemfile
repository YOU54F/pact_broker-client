source 'https://rubygems.org'

gemspec

# Not sure why jruby on Travis fails saying rake is not part of the bundle,
# even thought it's in the development dependencies. Trying it here.
gem 'rake', '~> 13.0'

group :development do
  gem 'fakefs', '~> 2.4'
  gem 'webmock', '~> 3.0'
  gem 'conventional-changelog', '~>1.3'
  gem 'pact', '~> 1.16'
  if ENV['X_PACT_DEVELOPMENT'] == 'true'
    gem 'pact-support', path: '../pact-support'
  else
    gem 'pact-support', '~> 1.16'
  end
  gem 'approvals', '0.0.26'
  gem 'rspec-its', '~> 1.3'
  gem 'pry-byebug'
  # sbmt-pact required deps
  gem "rspec-mocks"
  gem "activesupport"
  if ENV['X_PACT_DEVELOPMENT']
    gem 'sbmt-pact', path: '../sbmt-pact'
  else
    gem 'sbmt-pact', git: 'https://github.com/YOU54F/sbmt-pact.git', branch: 'feat/pact-ruby'
  end
end

group :test do
  gem 'faraday', '~>2.0'
  gem 'faraday-retry', '~>2.0'
  gem 'rack', '~> 2.1'
end
