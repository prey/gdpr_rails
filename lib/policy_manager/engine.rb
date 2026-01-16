module PolicyManager
  class Engine < ::Rails::Engine
    isolate_namespace PolicyManager
    config.paths.add 'lib/generators', eager_load: false
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.assets false
      g.helper false
    end
  end
end
