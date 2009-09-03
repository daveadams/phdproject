module TestBot
  attr_accessor :participant

  def login(p)
    @participant = p

    get "/"
    assert_response :success
    post_via_redirect "/login/login", :participant_number => @participant.participant_number
    assert_response(:success)
    assert_template(:tutorial)
    @participant.reload
  end

  def click_through_tutorial
    po = PageOrder.find(:first,
                        :conditions => ["experimental_group_id=? and phase=?",
                                        @participant.experimental_group.id,
                                        "tutorial"]).page_order
    assert_not_nil(po)
    po.each do |page|
      i = po.index(page)
      first_page = (i == 0)
      last_page = (i == (po.length - 1))
      prev_page_name = first_page ? nil : po[i-1]
      next_page_name = last_page ? nil : po[i+1]

      assert_equal("/tutorial/#{page}", path)
      unless last_page
        assert_select "form[method=get][action=/tutorial/#{next_page_name}]" do
          assert_select "input[value='Next >>']", 1
        end
      end
      unless first_page
        assert_select "form[method=get][action=/tutorial/#{prev_page_name}]" do
          assert_select "input[value='<< Back']", 1
        end
      end

      unless last_page
        get "/tutorial/#{next_page_name}"
        assert_response(:success)
        assert_template(:tutorial)
      end
    end

    @participant.reload
    assert_equal("tutorial", @participant.phase)
    assert_equal("complete", @participant.page)
  end

  def begin_experiment
    assert_equal("/tutorial/complete", path)
    assert_select("form[method=post][action=/tutorial/complete]") do
      assert_select("input[type=submit][value='BEGIN EXPERIMENT']", 1)
    end

    post_via_redirect("/tutorial/complete")
    assert_response(:success)
    assert_template(:experiment)
    assert_equal("/experiment/wait", path)

    @participant.reload
    assert_equal("experiment", @participant.phase)
    assert_equal("wait", @participant.page)
    assert_equal(true, @participant.tutorial_complete)
    assert_equal(false, @participant.experiment_complete)
    assert_equal(1, @participant.round)
  end

  def still_waiting
    @participant.reload
    assert_equal("experiment", @participant.phase)
    assert_equal("wait", @participant.page)

    get_via_redirect("/experiment/wait")
    assert_response(:success)
    assert_equal("/experiment/wait", path)

    @participant.reload
    assert_equal("experiment", @participant.phase)
    assert_equal("wait", @participant.page)

    if @participant.round == 1
      assert_equal(@participant.experimental_session.round, @participant.round)
    else
      assert_equal(@participant.experimental_session.round, @participant.round - 1)
    end
  end

  def start_round
    @participant.reload
    assert_equal("experiment", @participant.phase)
    #assert_equal("wait", @participant.page)
    assert_equal(@participant.experimental_session.round, @participant.round)

    get_via_redirect("/experiment/wait")
    assert_response(:success)
    assert_equal("/experiment/begin", path)

    @participant.reload
    assert_equal("experiment", @participant.phase)
    assert_equal("begin", @participant.page)
  end

  def complete_task
    @participant.reload
    assert_equal("/experiment/begin", path)
    assert_equal("experiment", @participant.phase)
    assert_equal("begin", @participant.page)
    assert_equal(@participant.experimental_session.round, @participant.round)

    # TODO: actually step through the various steps instead of faking it
    @participant.earn_income(1.0)
    @participant.pay_tax(-0.2)
    @participant.last_check = @participant.round
    @participant.save

    get_via_redirect("/experiment/end_round")
    assert_response(:success)

    @participant.reload
    assert_equal("experiment", @participant.phase)
    assert_equal(false, @participant.experiment_complete)

    if @participant.experimental_session.round == @participant.experimental_group.rounds
      assert_equal("/experiment/complete", path)
      assert_equal("complete", @participant.page)
    else
      assert_equal("/experiment/begin", path)
      assert_equal("begin", @participant.page)
    end
  end
end
