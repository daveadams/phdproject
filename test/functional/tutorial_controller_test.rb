require 'test_helper'

class TutorialControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :redirect
    assert_redirected_to(:controller => "login")
  end
end
