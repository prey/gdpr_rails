require 'spec_helper'

describe PolicyManager::CategoriesController  do
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
    PolicyManager::ApplicationController.any_instance.stubs(:current_user).returns(User.first)

  end

  it "should get index" do
    ApplicationController.any_instance.stubs(:current_user).returns(User.first)

    PolicyManager::Config.stubs(:is_admin?).returns(true)
    
    get :index
    assert_response :success
    assert_select "table td", "age"
  end

  it "should show category" do

    PolicyManager::Config.stubs(:is_admin?).returns(true)
    get :show , params: {id: @category}
    assert_response :success
    assert_select "h2", "age Policy"
    assert_select ".btn", "New Term"
  end


end
