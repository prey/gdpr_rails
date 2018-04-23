require 'test_helper'

module PolicyManager
  class PortabilityRequestsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @portability_request = policy_manager_portability_requests(:one)
    end

    test "should get index" do
      get portability_requests_url
      assert_response :success
    end

    test "should get new" do
      get new_portability_request_url
      assert_response :success
    end

    test "should create portability_request" do
      assert_difference('PortabilityRequest.count') do
        post portability_requests_url, params: { portability_request: { expire_at: @portability_request.expire_at, file: @portability_request.file, state: @portability_request.state, user_id: @portability_request.user_id } }
      end

      assert_redirected_to portability_request_url(PortabilityRequest.last)
    end

    test "should show portability_request" do
      get portability_request_url(@portability_request)
      assert_response :success
    end

    test "should get edit" do
      get edit_portability_request_url(@portability_request)
      assert_response :success
    end

    test "should update portability_request" do
      patch portability_request_url(@portability_request), params: { portability_request: { expire_at: @portability_request.expire_at, file: @portability_request.file, state: @portability_request.state, user_id: @portability_request.user_id } }
      assert_redirected_to portability_request_url(@portability_request)
    end

    test "should destroy portability_request" do
      assert_difference('PortabilityRequest.count', -1) do
        delete portability_request_url(@portability_request)
      end

      assert_redirected_to portability_requests_url
    end
  end
end
