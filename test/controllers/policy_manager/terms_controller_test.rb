require 'test_helper'

module PolicyManager
  class TermsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      #@term = terms_terms(:one)

      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", resources: [:internal, :external] })
      end

      @category = @config.rules.first.name
      @term = Term.create(description: "foo", rule: @category)

    end

    test "should get index" do
      get category_terms_url(@category)
      assert_response :success
    end

    test "should get new" do
      get new_category_term_url(@category)
      assert_response :success
    end

    test "should create term" do
      assert_difference('Term.count') do
        post category_terms_url(@category), params: { term: { rule: @category, description: "foo" } }
      end

      assert_redirected_to category_term_url(@category, Term.last)
    end

    test "should show term" do
      get category_term_url(@category, @term)
      assert_response :success
    end

    test "should get edit" do
      get edit_category_term_url(@category, @term)
      assert_response :success
    end

    test "should update term" do
      patch category_term_url(@category, @term), params: { term: { rule: @config.rules.first.name, description: "foo" } }
      assert_redirected_to category_term_url(@category, @term)
    end

    test "should destroy term" do
      assert_difference('Term.count', -1) do
        delete category_term_url(@category, @term)
      end

      assert_redirected_to category_terms_url(@category)
    end
  end
end
