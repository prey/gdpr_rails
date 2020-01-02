module PolicyManager
  class Engine < ::Rails::Engine
    isolate_namespace PolicyManager
    config.autoload_paths << File.expand_path("lib/generators", __dir__)
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      #g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
