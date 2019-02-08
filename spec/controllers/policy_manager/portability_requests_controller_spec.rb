require 'spec_helper'
module PolicyManager
  describe PortabilityRequestsController do

    routes { PolicyManager::Engine.routes }
    render_views

    before :each do

      @config = PolicyManager::Config.setup do |c|
        c.is_admin_method = ->(o){true}
        c.user_resource = 'User'
        c.from_email = "admin@acme.com"
        c.admin_email_inbox = "admin@acme.com"
        c.add_rule({name: "age",
          validates_on: [:create, :update],
          blocking: true,
          if: ->(o){ o.enabled_for_validation }
        })
        c.exporter = {
          path: Rails.root + "tmp/export",
          resource: 'User'
        }
      end

      if defined?(PolicyManager::PortabilityRequest)
        PolicyManager.send(:remove_const, :"PortabilityRequest")
        load PolicyManager::Engine.root + 'app/models/policy_manager/portability_request.rb'
      end

      @category = @config.rules.first.name

      @term = PolicyManager::Term.create(description: "desc 1", rule: "age")
      @term.publish!

      User.any_instance.stubs(:enabled_for_validation).returns(false)
      @user = User.new
      @user.email = "a@a.cl"
      @user.save
      PolicyManager::PortabilityRequest.delete_all
    end

    it "should get index empty records" do
      @controller.stubs(:allow_admins).returns(true)
      @controller.stubs(:current_user).returns(User.last)

      get :index
      assert PortabilityRequest.count == 0
      assert_response :success
    end

    it "should get index with records" do
      @controller.stubs(:allow_admins).returns(true)
      @controller.stubs(:current_user).returns(User.last)

      @user.portability_requests.create
      get :index
      assert PortabilityRequest.count == 1
      assert_response :success
    end

    it "confirm" do
      @controller.stubs(:allow_admins).returns(true)
      @controller.stubs(:current_user).returns(User.last)

      @user.portability_requests.create
      get :confirm, params: {id: @user.portability_requests.first.id }

      assert_response :redirect
      assert_predicate @user.portability_requests.first, :completed?
    end

    it "destroy" do
      @controller.stubs(:allow_admins).returns(true)
      @controller.stubs(:current_user).returns(User.last)

      @user.portability_requests.create
      delete :destroy, params: {id: @user.portability_requests.first.id }
      #follow_redirect!
      assert_response :redirect
      assert_equal @user.portability_requests.size, 0
    end

  end
end
