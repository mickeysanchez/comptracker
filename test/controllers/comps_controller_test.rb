require 'test_helper'

class CompsControllerTest < ActionController::TestCase
  setup do
    @comp = comps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:comps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create comp" do
    assert_difference('Comp.count') do
      post :create, comp: { account_id: @comp.account_id, days_until_expiration: @comp.days_until_expiration, description: @comp.description, expiration: @comp.expiration, user_id: @comp.user_id }
    end

    assert_redirected_to comp_path(assigns(:comp))
  end

  test "should show comp" do
    get :show, id: @comp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @comp
    assert_response :success
  end

  test "should update comp" do
    patch :update, id: @comp, comp: { account_id: @comp.account_id, days_until_expiration: @comp.days_until_expiration, description: @comp.description, expiration: @comp.expiration, user_id: @comp.user_id }
    assert_redirected_to comp_path(assigns(:comp))
  end

  test "should destroy comp" do
    assert_difference('Comp.count', -1) do
      delete :destroy, id: @comp
    end

    assert_redirected_to comps_path
  end
end
