require 'spec_helper'

describe PolicyManager::Term do
    
    before :each do
      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", validates_on: [:create, :update] })
      end
    end

    it "will require a rule" do
      t = PolicyManager::Term.create(description: "aaa")
      assert t.persisted? == false
      assert t.errors.any? == true
      assert t.errors[:rule].any? == true
    end

    it "create ok" do
      t = PolicyManager::Term.create(description: "aaa", rule: @config.rules.first.name)
      assert t.persisted? == true
    end

    it "get rule as an instance of Rule" do
      t = PolicyManager::Term.create(description: "aaa", rule: @config.rules.first.name)
      assert t.persisted? == true
      assert t.rule.instance_of?(PolicyManager::Rule) == true
    end

end
