require 'test_helper'

class TutorialTest < ActionController::IntegrationTest
  fixtures :all

  test "require session" do
    get "/tutorial"
    assert_response :redirect
    assert_redirected_to(:controller => "login")
    assert_equal(ActivityLog.count, 0)
  end

  test "require session follow redirect" do
    get_via_redirect "/tutorial"
    assert_response :success
    assert_equal "/", path
    assert_template :login
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::MUST_LOGIN
  end

  test "success with session" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.first
    post_via_redirect "/login/login", :participant_number => p.participant_number
    assert_response :success
    assert_template :tutorial
    assert_equal "/tutorial/intro", path

    p.reload
    assert_equal("tutorial", p.phase)
    assert_equal("intro", p.page)

    assert_equal(ActivityLog.count, 5)
    assert_equal(p.activity_logs.count, 3)
  end

  test "participant timestamps" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.last
    post("/login/login", :participant_number => p.participant_number)
    assert_response :redirect
    assert_redirected_to(:controller => :tutorial)

    p.reload
    assert_not_nil(p.first_login)
    assert_not_nil(p.last_access)
    assert_equal(p.first_login, p.last_access)
    assert(p.first_login.past?)
    assert(p.first_login > 1.second.ago)

    # wait long enough that timestamp will be different
    sleep 1

    get_via_redirect "/tutorial"
    assert_response :success

    p.reload
    assert_not_equal(p.first_login, p.last_access)
    assert(p.last_access > p.first_login)
    assert(p.last_access.past?)
  end

  test "failure when experimental session expires" do
    get "/"
    assert_response :success

    xs = experimental_sessions(:active)
    p = xs.participants.last
    post_via_redirect "/login/login", :participant_number => p.participant_number
    assert_response :success
    assert_template :tutorial
    assert_equal "/tutorial/intro", path

    # update the experimental session so that it's no longer active
    xs.is_active = false
    assert xs.save

    get "/tutorial"
    assert_response :redirect
    assert_redirected_to(:controller => "login")

    get_via_redirect "/tutorial"
    assert_response :success
    assert_equal "/", path
    assert_template :login
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::INACTIVE_SESSION
  end
end
