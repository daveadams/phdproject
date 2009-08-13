require 'test_helper'

class TutorialTest < ActionController::IntegrationTest
  fixtures :all

  MUST_LOGIN_TEXT = "You must login before using the application."
  INACTIVE_SESSION_TEXT = "This experimental session has ended. Please see the staff."

  test "require session" do
    get "/tutorial"
    assert_response :redirect
    assert_redirected_to(:controller => "login")
  end

  test "require session follow redirect" do
    get_via_redirect "/tutorial"
    assert_response :success
    assert_equal "/", path
    assert_template :login
    assert_select "title", "Log In"
    assert_select "div[class=error]", MUST_LOGIN_TEXT
  end

  test "success with session" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.first
    post_via_redirect "/login/login", :participant_number => p.participant_number
    assert_response :success
    assert_template :tutorial
    assert_equal "/tutorial", path
    assert_select "p", /filler/
  end

  test "failure when experimental session expires" do
    get "/"
    assert_response :success

    xs = experimental_sessions(:active)
    p = xs.participants.last
    post_via_redirect "/login/login", :participant_number => p.participant_number
    assert_response :success
    assert_template :tutorial
    assert_equal "/tutorial", path
    assert_select "p", /filler/

    # update the experimental session so that it's no longer valid
    xs.ends_at = 1.hour.ago
    assert xs.save

    get "/tutorial"
    assert_response :redirect
    assert_redirected_to(:controller => "login")

    get_via_redirect "/tutorial"
    assert_response :success
    assert_equal "/", path
    assert_template :login
    assert_select "title", "Log In"
    assert_select "div[class=error]", INACTIVE_SESSION_TEXT
  end
end
