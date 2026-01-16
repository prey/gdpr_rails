require 'spec_helper'

module PolicyManager
  describe TermsController do
    routes { PolicyManager::Engine.routes }
    render_views

    before :each do
      @config = PolicyManager::Config.setup do |c|
        c.is_admin_method = ->(_o) { true }
        c.add_rule({ name: 'age',
                     validates_on: %i[create update],
                     blocking: true,
                     if: ->(o) { o.enabled_for_validation } })
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

    it 'should get new' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      get :new, params: { category_id: @category }
      assert_response :success
    end

    it 'should create draft term' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      post :create, params: { category_id: @category, term: { rule: @category, description: 'foo' } }

      assert_redirected_to category_term_url(@category, Term.last)
      assert_predicate Term.last, :draft?
    end

    it 'should create published term' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      post :create,
           params: { category_id: @category, term: { rule: @category, description: 'foo', state: 'published' } }

      assert_redirected_to category_term_url(@category, Term.last)
      assert_predicate Term.last, :published?
    end

    it 'should show term' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      get :show, params: { category_id: @category, id: @term }
      assert_response :success
      assert_select '.badge-xl', @term.state.capitalize
    end

    it 'should get edit' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      get :edit, params: { category_id: @category, id: @term }
      assert_response :success
    end

    it 'should update term' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      patch :update, params: {
        id: @term.id,
        category_id: @category,
        term: {
          rule: @config.rules.first.name,
          description: 'foo'
        }
      }
      # assert_redirected_to category_term_url(@category, @term)
      assert_response :redirect
    end

    it 'should destroy term' do
      PolicyManager::Config.stubs(:is_admin?).returns(true)

      expect { delete :destroy, params: { id: @term.id, category_id: @category } }.to change(Term, :count).by(-1)

      # assert_redirected_to category_terms_url(@category)
      assert_response :redirect
    end
  end
end
