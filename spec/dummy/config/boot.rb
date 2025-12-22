# Set up gems listed in the Appraisal Gemfile when present (falls back to root Gemfile)
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../gemfiles/rails_6.1.gemfile', __dir__)
ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../Gemfile', __dir__) unless File.exist?(ENV['BUNDLE_GEMFILE'])

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
