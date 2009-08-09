require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success
    assert_select "title", "Log In"
  end

  test "empty post" do
    post :index
    assert_response :success
    assert_select "div[class=error]", "Invalid participant number."
  end
end
