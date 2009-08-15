require 'test_helper'

class LoginTest < ActionController::IntegrationTest
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

    post_via_redirect "/login/login", :participant_number => "invalid"
    assert_response :success
    assert_equal "/", path
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::INVALID_PARTICIPANT
  end

  test "active login attempt" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.first
    post "/login/login", :participant_number => p.participant_number
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")
  end

  test "inactive login attempt" do
    get "/"
    assert_response :success

    p = experimental_sessions("inactive").participants.first
    post_via_redirect("/login/login", :participant_number => p.participant_number)
    assert_response :success
    assert_equal "/", path
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::INVALID_PARTICIPANT
  end

  test "session setup" do
    get "/"
    assert_response :success
    assert_nil(session[:participant_id])

    p = experimental_sessions(:active).participants.first
    assert_equal(p.is_active, false)
    assert_nil(p.first_login)
    assert_nil(p.last_access)

    post "/login/login", :participant_number => p.participant_number
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
    post "/login/login", :participant_number => p.participant_number
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")

    p.reload
    assert_equal(p.is_active, true)

    post_via_redirect("/login/login", :participant_number => p.participant_number)
    assert_response :success
    assert_equal "/", path
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::ALREADY_ACTIVE
  end

  test "login redirect to saved location" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.first
    post_via_redirect "/login/login", :participant_number => p.participant_number
    assert_response :success
    assert_equal("/tutorial/intro", path)

    p.reload
    assert_equal("tutorial", p.phase)
    assert_equal("intro", p.page)

    p.is_active = false
    p.page = "complete"
    assert(p.save)

    post_via_redirect("/login/login", :participant_number => p.participant_number)
    assert_response :success
    assert_equal("/tutorial/complete", path)

    p.reload
    assert_equal("tutorial", p.phase)
    assert_equal("complete", p.page)

    p.is_active = false
    p.phase = "survey"
    p.page = "page4"
    assert(p.save)

    post("/login/login", :participant_number => p.participant_number)
    assert_response :redirect
    assert_redirected_to(:controller => "survey", :action => "page4")
  end
end
