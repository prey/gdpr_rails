require 'test_helper'

module PolicyManager
  class PortabilityRuleTest < ActiveSupport::TestCase
    
    def setup

      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", validates_on: [:create, :update], if: ->(o){false} })
        c.add_portability_rule({
          name: "exportable_data", 
          collection: :foo_data, 
          per: 10
        })

        c.add_portability_rule({
          name: "my_account", 
          member: :account_data
        })

      end

      if defined?(User)
        Object.send(:remove_const, :User)
        load Rails.root + 'app/models/user.rb'
      end

      pr = PolicyManager::Term.create(description: "el", rule: "age")
      pr.publish!
    end

    test "return a collection" do
      User.stub_any_instance(:foo_data, (1..100).map{|o| o} ) do
        @user = User.create(email: "a@a.cl")
        assert !@user.errors.any?

        collection = @user.portability_collection_exportable_data()
        assert collection.is_a?(Array)

        assert collection.size == 10

        collection = @user.portability_collection_exportable_data(2)
        assert collection.last == 20
      end
    end

    test "return a member" do
      User.stub_any_instance(:account_data, {name: "foo", last_name: "bar"} ) do
        @user = User.create(email: "a@a.cl")
        assert !@user.errors.any?

        member = @user.portability_member_my_account()
        assert member.is_a?(Hash)

        member = @user.portability_member_my_account()
        assert member[:name] == "foo"
      end
    end

  end
end
