require 'test_helper'

module PolicyManager
  class TermsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @term = terms_terms(:one)
    end

    test "should get index" do
      get terms_url
      assert_response :success
    end

    test "should get new" do
      get new_term_url
      assert_response :success
    end

    test "should create term" do
      assert_difference('Term.count') do
        post terms_url, params: { term: { category_id: @term.category_id, description: @term.description } }
      end

      assert_redirected_to term_url(Term.last)
    end

    test "should show term" do
      get term_url(@term)
      assert_response :success
    end

    test "should get edit" do
      get edit_term_url(@term)
      assert_response :success
    end

    test "should update term" do
      patch term_url(@term), params: { term: { category_id: @term.category_id, description: @term.description } }
      assert_redirected_to term_url(@term)
    end

    test "should destroy term" do
      assert_difference('Term.count', -1) do
        delete term_url(@term)
      end

      assert_redirected_to terms_url
    end
  end
end
