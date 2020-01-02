$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "policy_manager/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gdpr_rails"
  s.version     = PolicyManager::VERSION
  s.authors     = ["Miguel Michelson", "Prey inc"]
  s.email       = ["miguelmichelson@gmail.com"]
  s.homepage    = "http://preyproject.com"
  s.summary     = "policy_manager engine for rails"
  s.description = "policy_manager engine for rails gdpr compliance"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]
  s.add_dependency "rails", ">= 5.1.4", "< 7"
  s.add_dependency "redcarpet"
  s.add_dependency "will_paginate"
  s.add_dependency "aasm"
  s.add_dependency "rubyzip", '>= 1.0.0'
  s.add_dependency "paperclip"
  s.add_dependency "groupdate", "4.0.0"
  s.add_dependency "chartkick", "2.3.4"
  #s.add_dependency "kaminari"
  s.add_development_dependency "mocha"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
