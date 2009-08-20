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
    ExperimentalSession.destroy_all
    assert_equal(0, ExperimentalSession.count)

    x = ExperimentalSession.new(:name => "Test Active Session",
                                :is_active => true)
    assert x.is_active

    assert x.valid?
    assert x.save
  end

  test "create participants" do
    ExperimentalSession.destroy_all
    assert_equal(0, ExperimentalSession.count)

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
    ExperimentalSession.destroy_all
    assert_equal(0, ExperimentalSession.count)

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
    ExperimentalSession.destroy_all
    assert_equal(0, ExperimentalSession.count)

    x1 = ExperimentalSession.new(:name => "Test1", :is_active => false)
    assert(x1.save)

    x2 = ExperimentalSession.new(:name => "Test1", :is_active => false)
    assert(x2.save)

    x3 = ExperimentalSession.new(:name => "Test1", :is_active => false)
    assert(x3.save)

    assert_nothing_raised { x1.set_active }
    x1.reload
    assert(x1.is_active)
    assert_equal(x1, ExperimentalSession.active)

    assert_raise(ActiveRecord::RecordInvalid) { x2.set_active }
    x2.reload
    assert(!x2.is_active)
    assert_equal(x1, ExperimentalSession.active)
  end
end
