require 'test_helper'

class ExperimentalSessionTest < ActiveSupport::TestCase
  test "new inactive" do
    x = ExperimentalSession.new(:name => "Test Inactive Session",
                                :is_active => false)
    assert !x.is_active

    assert x.valid?
    assert x.save
  end

  test "new active" do
    x = ExperimentalSession.new(:name => "Test Active Session",
                                :is_active => true)
    assert x.is_active

    assert x.valid?
    assert x.save
  end

  test "create participants" do
    x = ExperimentalSession.new(:name => "A Test Session",
                                :is_active => true)
    assert x.valid?
    assert x.save

    n = 10
    participants = x.create_participants(n, experimental_groups(:control))

    assert_equal(participants.length, n)
    participants.each do |p|
      assert_equal(p.experimental_session, x)
      assert_equal(p.experimental_group, experimental_groups(:control))
      assert(p.id)
      assert_equal(Participant.find(p.id), p)
    end
  end

  test "round counts" do
    x = ExperimentalSession.new(:name => "Testing Round Counts",
                                :is_active => true)
    assert x.valid?
    assert x.save

    assert_equal(0, x.max_rounds)

    x.create_participants(2, experimental_groups(:control))
    x.create_participants(2, experimental_groups(:experimental_one))

    x.reload
    x.participants.each do |p|
      assert_equal(20, p.experimental_group.rounds)
    end

    assert_equal(20, x.max_rounds)

    x.create_participants(2, experimental_groups(:ten_rounds))
    x.reload

    assert(!x.valid?)
    assert_nil(x.max_rounds)
  end

  test "only one active" do
    x1 = ExperimentalSession.new(:name => "Test1")
    assert(x1.save)
    assert_equal(false, x1.is_active)
    assert_nil(x1.started_at)

    x2 = ExperimentalSession.new(:name => "Test2")
    assert(x2.save)
    assert_equal(false, x2.is_active)

    x3 = ExperimentalSession.new(:name => "Test3")
    assert(x3.save)
    assert_equal(false, x3.is_active)

    assert_nothing_raised { x1.set_active }
    x1.reload
    assert(x1.is_active)
    assert_equal(x1, ExperimentalSession.active)
    assert_not_nil(x1.started_at)

    assert_raise(ActiveRecord::RecordInvalid) { x2.set_active }
    x2.reload
    assert(!x2.is_active)
    assert_equal(x1, ExperimentalSession.active)
  end

  test "set active then set complete" do
    x = ExperimentalSession.new(:name => "Test1")
    assert(x.save)
    assert_equal(false, x.is_active)
    assert_equal(false, x.is_complete)
    assert_nil(x.started_at)
    assert_nil(x.ended_at)

    assert_raise(ExperimentalSessionNotActive) { x.set_complete }

    assert_nothing_raised { x.set_active }
    assert_equal(true, x.is_active)
    assert_equal(false, x.is_complete)
    assert_not_nil(x.started_at)
    assert_nil(x.ended_at)

    assert_raise(ExperimentalSessionAlreadyActive) { x.set_active }

    sleep 1
    assert(x.started_at < Time.now)

    assert_nothing_raised { x.set_complete }
    assert_equal(false, x.is_active)
    assert_equal(true, x.is_complete)
    assert_not_nil(x.started_at)
    assert_not_nil(x.ended_at)

    assert_raise(ExperimentalSessionAlreadyComplete) { x.set_active }

    sleep 1
    assert(x.started_at < Time.now)
    assert(x.ended_at < Time.now)
  end

  test "lockdown" do
    x = ExperimentalSession.new(:name => "Test1")
    assert(x.save)
    assert_equal(false, x.is_active)
    assert_equal(false, x.is_locked_down)
    assert_equal(false, x.is_complete)

    assert_raise(ExperimentalSessionNotActive) { x.lockdown }

    assert_nothing_raised { x.create_participants(100, experimental_groups(:control)) }
    x.reload

    assert_equal(100, x.participants.count)
    assert_equal(20, x.max_rounds)

    assert_nothing_raised { x.set_active }
    assert_equal(true, x.is_active)
    assert_equal(false, x.is_locked_down)
    assert_equal(false, x.is_complete)
    assert_equal(0, x.current_participants.count)
    assert_equal(100, x.unseen_participants.count)

    0.upto 19 do |i|
      assert_nothing_raised { x.participants[i].login }
    end

    x.reload
    assert_equal(20, x.current_participants.count)
    assert_equal(80, x.unseen_participants.count)

    assert_nothing_raised { x.lockdown }
    x.reload
    assert_equal(true, x.is_locked_down)
    assert_equal(20, x.current_participants.count)
    assert_equal(0, x.unseen_participants.count)

    assert_raise(ExperimentalSessionAlreadyLockedDown) { x.lockdown }
    assert_raise(ExperimentalSessionAlreadyLockedDown) {
      x.create_participants(100, experimental_groups(:control))
    }

    assert_equal(true, x.is_locked_down)
    assert_equal(20, x.current_participants.count)
    assert_equal(0, x.unseen_participants.count)

    assert_nothing_raised { x.set_complete }
    x.reload
    assert_equal(false, x.is_active)
    assert_equal(true, x.is_locked_down)
    assert_equal(true, x.is_complete)
    assert_equal(20, x.current_participants.count)
    assert_equal(0, x.unseen_participants.count)
  end
end
