require 'spec_helper'

module PolicyManager
  describe UserTermsController do

    routes { PolicyManager::Engine.routes }
    render_views

    before :each do 

      @config = PolicyManager::Config.setup do |c|
        c.is_admin_method = ->(o){true}
        c.add_rule({name: "age", 
          validates_on: [:create, :update],
          blocking: true, 
          if: ->(o){ o.enabled_for_validation } 
        })
      end

      @category = @config.rules.first.name

      pr = PolicyManager::Term.create(description: "el", rule: "age")
      pr.publish!

      User.any_instance.stubs(:enabled_for_validation).returns(false)
      @user = User.new
      @user.email = "a@a.cl"
      @user.save
      ApplicationController.any_instance.stubs(:current_user).returns(User.first)
    end

    it "should get pendings as html" do
      get :pending
      assert_response :success
      assert Nokogiri::HTML.parse(response.body).css("main ul li").text == "age"
    end

    it "should get pendings as json" do
      get :pending, as: :json
      assert JSON.parse(response.body).size == 1
      assert JSON.parse(response.body).first["name"] == "age"
      assert_response :success
    end

    it "should show as html" do
      get :show, {params:{id: "age"}}
      assert_response :success
    end

    it "should show as json" do
      get :show, params:{id: "age"}, as: :json
      assert_response :success
    end

    it "should accept user term" do
      UserTerm.delete_all
      put :accept, params:{id: "age"}, as: :json
      assert_response :success
      assert @user.pending_policies.size == 0
    end

    it "should reject user term" do
      UserTerm.delete_all
      put :reject , params:{id: "age"}, as: :json
      assert_response :success
      assert @user.pending_policies.size == 1
    end

    it "accept multiples" do
      UserTerm.delete_all
      put :accept_multiples, params: { user: { policy_rule_age: true } }, as: :json
      assert_response :success
      assert @user.pending_policies.size == 0
    end

    it "reject multiples" do
      UserTerm.delete_all
      put :accept_multiples, params: { user: { policy_rule_age: false } }, as: :json
      assert_response :success
      binding.pry
      assert @user.pending_policies.size == 1
    end

    it "blocking terms" do 
      UserTerm.delete_all
      get :blocking_terms, as: :json
      assert_response :success
      assert JSON.parse(response.body).size == 1
    end

  end
end
