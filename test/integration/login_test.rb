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

    assert_equal(ActivityLog.count, 1)
    log_entry = ActivityLog.find(:first)
    assert_nil(log_entry.participant)
    assert_equal(log_entry.event, ActivityLog::PAGE_LOADED)
    assert_equal(log_entry.controller, "login")
    assert_equal(log_entry.action, "index")
  end

  # an invalid participant number should be rejected
  test "failed login" do
    get "/"
    assert_response :success
    assert_equal(ActivityLog.count, 1)

    post_via_redirect "/login/login", :participant_number => "invalid"
    assert_response :success
    assert_equal "/", path
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::INVALID_PARTICIPANT

    assert_equal(ActivityLog.count, 4)
  end

  test "active login attempt" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.first
    post "/login/login", :participant_number => p.participant_number
    assert_response :redirect
    assert_redirected_to(:controller => "tutorial")

    assert_equal(ActivityLog.count, 3)
    login_entry = ActivityLog.find_by_event(ActivityLog::LOGIN)
    assert_not_nil(login_entry)
    assert_equal(login_entry.controller, "login")
    assert_equal(login_entry.action, "login")
    assert_equal(login_entry.participant, p)

    load_entry = ActivityLog.find(:first,
                                  :conditions => {
                                    :event => ActivityLog::PAGE_LOADED,
                                    :action => "login" })
    assert_not_nil(load_entry)
    assert_equal(load_entry.controller, "login")
    assert_equal(load_entry.action, "login")
    assert_nil(load_entry.participant)
    assert_not_nil(load_entry.details)
    assert_nothing_raised { YAML::load(load_entry.details) }

    details = YAML::load(load_entry.details)
    assert_not_nil(details)
    assert_not_nil(details[:participant_number])
    assert_equal(details[:participant_number], p.participant_number)
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

  test "active session login bounce" do
    get "/"
    assert_response :success

    p = experimental_sessions(:active).participants.last
    post_via_redirect("/login/login", :participant_number => p.participant_number)
    assert_response :success
    assert_equal("/tutorial/intro", path)

    assert_equal(ActivityLog.count, 5)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::ERROR).count, 0)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::PAGE_LOADED).count, 4)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::LOGIN).count, 1)

    p.reload
    assert_equal(p.is_active, true)
    assert_equal(p.phase, "tutorial")
    assert_equal(p.page, "intro")

    get_via_redirect "/"
    assert_response :success
    assert_equal("/tutorial/intro", path)

    assert_equal(ActivityLog.count, 8)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::OUT_OF_SEQUENCE).count, 1)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::PAGE_LOADED).count, 6)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::LOGIN).count, 1)

    post_via_redirect("/login/login", :participant_number => p.participant_number)
    assert_response :success
    assert_equal("/tutorial/intro", path)

    assert_equal(ActivityLog.count, 11)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::OUT_OF_SEQUENCE).count, 2)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::PAGE_LOADED).count, 8)
    assert_equal(ActivityLog.find_all_by_event(ActivityLog::LOGIN).count, 1)
  end

  test "reject already-active login attempt" do
    # TODO: Figure out how to emulate multiple sessions

    # p = experimental_sessions(:active).participants.last

    # open_session do
    #   get "/"
    #   assert_response :success

    #   post_via_redirect("/login/login", :participant_number => p.participant_number)
    #   assert_response :success
    #   assert_equal("/tutorial/intro", path)
    # end

    # p.reload
    # assert_equal(p.is_active, true)
    # assert_equal(p.phase, "tutorial")
    # assert_equal(p.page, "intro")

    # open_session do
    #   get "/"
    #   assert_response :success
    #   assert_equal("/", path)

    #   post_via_redirect("/login/login", :participant_number => p.participant_number)
    #   assert_response :success
    #   assert_equal("/", path)
    #   assert_select "title", "Log In"
    #   assert_select "div[class=error]", ErrorStrings::ALREADY_ACTIVE
    # end

    # error_entries = ActivityLog.find_all_by_event(ActivityLog::ERROR)
    # assert_equal(error_entries.length, 1)
    # error_entry = error_entries.first
    # assert_equal(error_entry.participant, p)
    # assert(error_entry.details =~ /#{p.participant_number}/)
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
