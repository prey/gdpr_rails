require 'test_helper'

module PolicyManager
  class TermTest < ActiveSupport::TestCase
    
    def config
      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", validates_on: [:create, :update] })
      end
    end

    test "will require a rule" do
      t = PolicyManager::Term.create(description: "aaa")
      assert t.persisted? == false
      assert t.errors.any? == true
      assert t.errors[:rule].any? == true
    end

    test "create ok" do
      t = PolicyManager::Term.create(description: "aaa", rule: config.rules.first.name)
      assert t.persisted? == true
    end

    test "get rule as an instance of Rule" do
      t = PolicyManager::Term.create(description: "aaa", rule: config.rules.first.name)
      assert t.persisted? == true
      assert t.rule.instance_of?(PolicyManager::Rule) == true
    end

  end
end
