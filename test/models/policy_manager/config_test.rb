require 'test_helper'

module PolicyManager
  class ConfigTest < ActiveSupport::TestCase
    test "return empty rules" do
      config = PolicyManager::Config.setup do
      end
      assert config.rules == [] 
    end

    test "add rule default" do
      config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age" })
      end
      assert config.rules.size == 1
      assert config.rules.first.name == "age"
      assert config.rules.first.resources == [:internal]
    end

    test "add rule resources" do
      config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", resources: [:internal, :external] })
      end
      assert config.rules.size == 1
      assert config.rules.first.name == "age"
      assert config.rules.first.resources == [:internal, :external]
    end

  end
end
