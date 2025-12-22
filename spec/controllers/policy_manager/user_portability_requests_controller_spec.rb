require 'spec_helper'

module PolicyManager
  describe UserPortabilityRequestsController do
    routes { PolicyManager::Engine.routes }
    render_views

    before :each do
      @config = PolicyManager::Config.setup do |c|
        c.is_admin_method = ->(_o) { true }
        c.from_email = 'admin@acme.com'
        c.admin_email_inbox = 'admin@acme.com'
        c.add_rule({ name: 'age',
                     validates_on: %i[create update],
                     blocking: true,
                     if: ->(o) { o.enabled_for_validation } })
        c.exporter = {
          path: Rails.root + 'tmp/export',
          resource: User
        }
      end

      @category = @config.rules.first.name

      @term = PolicyManager::Term.create(description: 'desc 1', rule: 'age')
      @term.publish!

      User.any_instance.stubs(:enabled_for_validation).returns(false)
      @user = User.new
      @user.email = 'a@a.cl'
      @user.save
      ApplicationController.any_instance.stubs(:current_user).returns(User.first)
    end

    it 'should get index' do
      get :index
      assert_response :success
    end

    it 'create on enabled' do
      post :create
      assert_redirected_to user_portability_requests_path
      assert_response :redirect
      expect(@user.portability_requests.size).to be == 1
      # follow_redirect!
      # assert_select "div", I18n.t("terms_app.user_portability_requests.index.created")
    end

    it 'create when has pending' do
      @user.portability_requests.create
      post :create
      assert_redirected_to user_portability_requests_path
      assert_response :redirect
      expect(@user.portability_requests.size).to be == 1
      # follow_redirect!
      # assert_select "div", I18n.t("terms_app.user_portability_requests.index.has_pending")
    end

    it 'create on enabled as json' do
      post :create, format: :json
      assert_response :success
      assert JSON.parse(response.body)['notice'] == I18n.t('terms_app.user_portability_requests.index.created')
    end

    it 'create when has pending as json' do
      @user.portability_requests.create
      post :create, format: :json
      assert_response 422
      assert JSON.parse(response.body)['notice'] == I18n.t('terms_app.user_portability_requests.index.has_pending')
    end
  end
end
