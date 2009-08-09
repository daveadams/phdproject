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
    assert_select "div[class=error]", 0
  end

  # an invalid participant number should be rejected
  test "failed login" do
    get "/"
    assert_response :success

    post "/", :participant_number => "invalid"
    assert_response :success
    assert_select "div[class=error]", "Invalid participant number."
  end

  test "active login attempt" do
    get "/"
    assert_response :success

    active_participant = experimental_sessions("active").participants.first
    post "/", :participant_number => active_participant[:participant_number]
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")
  end

  test "inactive login attempt" do
    get "/"
    assert_response :success

    inactive_participant = experimental_sessions("inactive").participants.first
    post "/", :participant_number => inactive_participant[:participant_number]
    assert_response :success
    assert_select "div[class=error]", "Invalid participant number."
  end
end
