require 'test_helper'

class ParticipantTest < ActionController::IntegrationTest
  fixtures :all

  # / should get us to the login page
  test "first visit" do
    get "/"
    assert_response :success
    assert_template :login
    assert_select "title", "Log In"
    assert_select "form" do
      assert_select "input", :count => 2
      assert_select "input[name=?]", "participant_number"
      assert_select "input[type=submit][value=?]", "Log In"
    end
    # TODO: no warning message should appear at this point
  end

  # an invalid participant number should be rejected
  test "failed login" do
    get "/"
    assert_response :success

    post "/", :participant_number => "invalid"
    assert_response :success
  end
end
