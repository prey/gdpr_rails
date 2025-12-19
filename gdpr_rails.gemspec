$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'policy_manager/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'gdpr_rails'
  s.version = PolicyManager::VERSION
  s.authors = ['Miguel Michelson', 'Prey inc']
  s.email = ['miguelmichelson@gmail.com', 'tec@preyproject.com']
  s.homepage = 'http://preyproject.com'
  s.summary = 'policy_manager engine for rails'
  s.description = 'policy_manager engine for rails gdpr compliance'
  s.license = 'MIT'
  s.required_ruby_version = '>= 3.0'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.add_dependency 'aasm'
  s.add_dependency 'chartkick', '3.4.2'
  s.add_dependency 'groupdate'
  s.add_dependency 'rails', '>= 6.1', '< 7.1'
  s.add_dependency 'redcarpet'
  s.add_dependency 'rubyzip'
  s.add_dependency 'will_paginate'
  # s.add_dependency "kaminari"
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3', '~> 1.6'
  s.metadata['rubygems_mfa_required'] = 'true'
end
