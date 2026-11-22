require 'spec_helper'

describe PolicyManager::UserPortabilityRequestsController do
  routes { PolicyManager::Engine.routes }
  render_views

  before do
    PolicyManager::Config.setup { |c| c.is_admin_method = ->(_o) { false } }
    PolicyManager::ApplicationController.any_instance.stubs(:current_user).returns(nil)
  end

  it 'renders the 401 page for anonymous users' do
    get :index
    assert_response :unauthorized
    assert_select 'h1', /not authorized|error page/
  end
end
