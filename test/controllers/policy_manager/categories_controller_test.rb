require 'test_helper'

module PolicyManager
  class CategoriesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @config = PolicyManager::Config.setup do |c|
        c.add_rule({name: "age", resources: [:internal, :external] })
      end
      @category = @config.rules.first.name
    end

    test "should get index" do
      get categories_url
      assert_response :success
    end

    test "should show category" do
      get category_url(@category)
      assert_response :success
    end

  end
end
