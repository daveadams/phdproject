require 'test_helper'

class TutorialTest < ActionController::IntegrationTest
  fixtures :all

  test "require session" do
    get "/tutorial"
    assert_response :redirect
    assert_redirected_to(:controller => "login")
    assert_equal(ActivityLog.count, 1)
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
    xs = experimental_sessions(:inactive)
    assert_nothing_raised { xs.create_participants(5, experimental_groups(:control)) }
    assert_nothing_raised { xs.set_active }

    get "/"
    assert_response :success

    p = xs.participants.first
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
    xs = experimental_sessions(:inactive)
    assert_nothing_raised { xs.create_participants(5, experimental_groups(:experimental_two)) }
    assert_nothing_raised { xs.set_active }

    get "/"
    assert_response :success

    p = xs.participants.last
    post("/login/login", :participant_number => p.participant_number)
    assert_response :redirect
    assert_redirected_to(:controller => :tutorial)

    p.reload
    assert_not_nil(p.first_login)
    assert_not_nil(p.last_access)
    assert_equal(p.first_login, p.last_access)
    assert(p.first_login.past?)
    assert(p.first_login > 1.second.ago)

    sleep 1

    get_via_redirect "/tutorial"
    assert_response :success

    p.reload
    assert_not_equal(p.first_login, p.last_access)
    assert(p.last_access > p.first_login)
    assert(p.last_access.past?)
  end

  test "failure when experimental session expires" do
    xs = experimental_sessions(:inactive)
    assert_nothing_raised { xs.create_participants(5, experimental_groups(:control)) }
    assert_nothing_raised { xs.set_active }

    get "/"
    assert_response :success

    p = xs.participants.last
    post_via_redirect "/login/login", :participant_number => p.participant_number
    assert_response :success
    assert_template :tutorial
    assert_equal "/tutorial/intro", path

    assert_nothing_raised { xs.set_complete }

    get_via_redirect "/tutorial"
    assert_response :success
    assert_equal "/", path
    assert_template :login
    assert_select "title", "Log In"
    assert_select "div[class=error]", ErrorStrings::INACTIVE_SESSION
  end

  test "forward sequence" do
    xs = experimental_sessions(:inactive)
    xgids = [:control, :context_neutral, :experimental_one, :experimental_two]
    xgids.each do |xgid|
      assert_nothing_raised { xs.create_participants(1, experimental_groups(xgid)) }
    end
    xs.reload
    assert_equal(xs.participants.count, xgids.length)
    assert_nothing_raised { xs.set_active }

    xs.participants.each do |p|
      open_session do |s|
        s.post_via_redirect("/login/login",
                            :participant_number => p.participant_number)
        s.assert_response(:success)
        s.assert_template(:tutorial)

        po = PageOrder.find(:first,
                            :conditions => ["experimental_group_id=? and phase=?",
                                            p.experimental_group.id, "tutorial"]).page_order

        po.each do |page|
          i = po.index(page)
          first_page = (i == 0)
          last_page = (i == (po.length - 1))
          prev_page_name = first_page ? nil : po[i-1]
          next_page_name = last_page ? nil : po[i+1]

          assert_equal("/tutorial/#{page}", s.path)
          unless last_page
            s.assert_select "form[method=get][action=/tutorial/#{next_page_name}]" do
              s.assert_select "input[value='Next >>']", 1
            end
          end
          unless first_page
            s.assert_select "form[method=get][action=/tutorial/#{prev_page_name}]" do
              s.assert_select "input[value='<< Back']", 1
            end
          end

          unless last_page
            s.get "/tutorial/#{next_page_name}"
            s.assert_response(:success)
            s.assert_template(:tutorial)
          end
        end

        p.reload
        assert_equal("tutorial", p.phase)
        assert_equal("complete", p.page)
      end
    end
  end
end
