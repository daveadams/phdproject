require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success
    assert_select "title", "Login"
    # TODO: no warning message should appear at this point
  end

  test "simple post" do
    post :index
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")
  end
end
