require 'test_helper'

class ExperimentalSessionTest < ActiveSupport::TestCase
  test "new inactive" do
    x = ExperimentalSession.new(:name => "Test Inactive Session",
                                :starts_at => 3.days.ago.to_s(:db),
                                :ends_at => 2.days.ago.to_s(:db))
    assert !x.is_active?

    assert x.valid?
    assert x.save
  end

  test "new active" do
    x = ExperimentalSession.new(:name => "Test Active Session",
                                :starts_at => 1.days.ago.to_s(:db),
                                :ends_at => 1.days.from_now.to_s(:db))
    assert x.is_active?

    assert x.valid?
    assert x.save
  end

  test "create participants" do
    x = ExperimentalSession.new(:name => "A Test Session",
                                :starts_at => 1.days.ago.to_s(:db),
                                :ends_at => 1.days.from_now.to_s(:db))
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
end
