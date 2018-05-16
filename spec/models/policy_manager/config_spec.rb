require 'spec_helper'

describe PolicyManager::Config do
  it "return empty rules" do
    config = PolicyManager::Config.setup do
    end
    assert config.rules == [] 
  end

  it "add rule default" do
    config = PolicyManager::Config.setup do |c|
      c.add_rule({ name: "age" })
    end
    assert config.rules.size == 1
    assert config.rules.first.name == "age"
    assert config.rules.first.validates_on == nil #== [:create]
  end

  it "add rule on" do
    config = PolicyManager::Config.setup do |c|
      c.add_rule({ name: "age", validates_on: [:create, :update] })
    end
    assert config.rules.size == 1
    assert config.rules.first.name == "age"
    assert config.rules.first.validates_on == [:create, :update]
  end

end

