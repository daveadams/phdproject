require 'test_helper'

class ExperimentControllerTest < ActionController::TestCase
  test "get index with no session" do
    get :index
    assert_response :redirect
    assert_redirected_to(:controller => "login")
  end
end
