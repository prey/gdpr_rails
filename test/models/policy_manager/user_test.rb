require 'test_helper'

module PolicyManager
  class UserTest < ActiveSupport::TestCase

    def config
      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", resources: [:internal, :external] })
      end
    end

    test "dummy user creation" do
      user = User.create(email: "a@a.cl")
      assert user.persisted?
     end

    test "get policies on empty terms will not return pending policies" do
      config
      user = User.create(email: "a@a.cl")
      assert user.pending_policies.size == 0
    end

    test "get policies on existing terms will return pending policies" do
      config
      PolicyManager::Term.create(description: "aaa", rule: config.rules.first.name)
      user = User.create(email: "a@a.cl")
      assert user.pending_policies.size == 1
      assert user.needs_policy_confirmation_for?(config.rules.first.name)
    end

    test "accept policies will empty pending policies" do
      config
      PolicyManager::Term.create(description: "aaa", rule: config.rules.first.name)
      user = User.create(email: "a@a.cl")
      assert user.pending_policies.size == 1
      user_term = user.handle_policy_for(config.rules.first.terms.last)
      user_term.accept!
      assert user.pending_policies.size == 0
    end

  end
end
