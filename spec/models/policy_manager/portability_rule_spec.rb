require 'spec_helper'

describe PolicyManager::PortabilityRule do
  before :each do
    @config = PolicyManager::Config.setup do |c|
      c.add_rule({ name: 'age', validates_on: %i[create update], if: ->(_o) { false } })
      c.add_portability_rule({
                               name: 'exportable_data',
                               collection: :foo_data,
                               per: 20
                             })

      c.add_portability_rule({
                               name: 'my_account',
                               member: :account_data
                             })
    end

    if defined?(User)
      Object.send(:remove_const, :User)
      load Rails.root + 'app/models/user.rb'
    end

    pr = PolicyManager::Term.create(description: 'el', rule: 'age')
    pr.publish!
  end

  it 'return a collection' do
    User.any_instance.stubs(:foo_data).returns((1..100).map { |o| o })
    @user = User.create(email: 'a@a.cl')
    assert !@user.errors.any?
    collection = @user.portability_collection_exportable_data
    assert collection.is_a?(Array)
    assert collection.size == 20
    collection = @user.portability_collection_exportable_data(2)
    assert collection.last == 40
  end

  it 'return a member' do
    User.any_instance.stubs(:account_data).returns({ name: 'foo', last_name: 'bar' })
    @user = User.create(email: 'a@a.cl')
    assert !@user.errors.any?
    member = @user.portability_member_my_account
    assert member.is_a?(Hash)
    member = @user.portability_member_my_account
    assert member[:name] == 'foo'
  end
end
