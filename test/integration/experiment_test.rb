require 'test_helper'
require 'test_bot'

class ExperimentTest < ActionController::IntegrationTest
  fixtures :all

  test "single through all rounds" do
    xs = experimental_sessions(:inactive)
    xs.create_participants(1, experimental_groups(:control))
    xs.set_active
    xs.reload

    s = open_session { |sess| sess.extend(TestBot) }

    s.login(xs.participants.first)
    s.click_through_tutorial

    assert_equal(false, xs.phase_complete?)
    s.begin_experiment

    xs.reload
    assert_equal(true, xs.phase_complete?)

    s.still_waiting
    s.still_waiting
    s.still_waiting
    s.still_waiting

    xs.reload
    assert_equal(1, xs.round)
    assert_equal("tutorial", xs.phase)

    xs.next_phase
    xs.reload
    assert_equal(1, xs.round)
    assert_equal("experiment", xs.phase)
    assert_equal(false, xs.phase_complete?)
    assert_equal(false, xs.round_complete?)

    s.start_round
    s.complete_task

    2.upto(s.participant.experimental_group.rounds) do |current_round|
      xs.reload
      assert_equal(current_round - 1, xs.round)
      assert_equal("experiment", xs.phase)
      assert_equal(false, xs.phase_complete?)
      assert_equal(true, xs.round_complete?)

      s.still_waiting
      s.still_waiting

      xs.next_round
      xs.reload
      assert_equal(current_round, xs.round)
      assert_equal("experiment", xs.phase)
      assert_equal(false, xs.phase_complete?)
      assert_equal(false, xs.round_complete?)

      s.start_round
      s.complete_task
    end

    assert_equal("/experiment/complete", s.path)
    s.participant.reload
    assert_equal("experiment", s.participant.phase)
    assert_equal("complete", s.participant.page)
    assert_equal(false, s.participant.experiment_complete)

    xs.reload
    assert_equal(s.participant.experimental_group.rounds, xs.round)
    assert_equal("experiment", xs.phase)
    assert_equal(false, xs.phase_complete?)
  end
end
