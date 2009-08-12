require 'test_helper'

class LoginTest < ActionController::IntegrationTest
  fixtures :all

  INVALID_TEXT = "Invalid participant number. Please try again."
  ALREADY_ACTIVE_TEXT = "That participant number is already in use. Please notify the staff."

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
    assert_select "div[class=error]", INVALID_TEXT
  end

  test "active login attempt" do
    get "/"
    assert_response :success

    active_participant = experimental_sessions(:active).participants.first
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
    assert_select "div[class=error]", INVALID_TEXT
  end

  test "session setup" do
    get "/"
    assert_response :success
    assert_nil(session[:participant_id])

    p = experimental_sessions(:active).participants.first
    assert_equal(p.is_active, false)
    assert_nil(p.first_login)
    assert_nil(p.last_access)

    post "/", :participant_number => p.participant_number
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")
    assert_not_nil(session[:participant_id])
    assert_equal(session[:participant_id], p.id)

    p.reload
    assert_equal(p.is_active, true)
    assert_not_nil(p.first_login)
    assert_not_nil(p.last_access)
    assert_equal(p.first_login, p.last_access)
  end

  test "login failure when already active" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.last
    post "/", :participant_number => p.participant_number
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")

    p.reload
    assert_equal(p.is_active, true)

    post "/", :participant_number => p.participant_number
    assert_response :success

    assert_select "div[class=error]", ALREADY_ACTIVE_TEXT
  end
end
