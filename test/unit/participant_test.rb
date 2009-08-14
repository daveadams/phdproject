require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  test "new participant" do
    p = Participant.new
    p.experimental_session = experimental_sessions(:active)
    p.experimental_group = experimental_groups(:experimental_one)

    assert(p.valid?)
    assert(p.save)

    assert_not_nil(p.participant_number)
    assert_equal(p.experimental_session, experimental_sessions(:active))
    assert_equal(p.experimental_group, experimental_groups(:experimental_one))
    assert_equal(p.is_active, false)
  end

  test "new participant with args" do
    p = Participant.new(:experimental_session => experimental_sessions(:active),
                        :experimental_group => experimental_groups(:experimental_two))
    assert(p.valid?)
    assert(p.save)

    assert_not_nil(p.participant_number)
    assert_equal(p.experimental_session, experimental_sessions(:active))
    assert_equal(p.experimental_group, experimental_groups(:experimental_two))
    assert_equal(p.is_active, false)
  end

  test "experimental session validation" do
    p = Participant.new
    assert !p.valid?
    assert !p.save

    p.experimental_group = experimental_groups(:control)
    assert !p.valid?
    assert !p.save

    p.experimental_group = nil
    p.experimental_session = experimental_sessions(:inactive)
    assert !p.valid?
    assert !p.save

    p.experimental_group = experimental_groups(:context_neutral)
    assert p.valid?
    assert p.save
  end

  test "participant number override on new" do
    my_partnum = "not a real partnum"
    p = Participant.new(:experimental_session => experimental_sessions(:inactive),
                        :experimental_group => experimental_groups(:control),
                        :participant_number => my_partnum)
    assert p.save
    assert_not_equal(p.participant_number, my_partnum)
  end

  test "is_active override on new" do
    p = Participant.new(:experimental_session => experimental_sessions(:inactive),
                        :experimental_group => experimental_groups(:control),
                        :is_active => true)
    assert p.save
    assert_equal(p.is_active, false)
  end

  test "create participant" do
    assert_raise(ActiveRecord::RecordInvalid) { Participant.create! }
    assert_raise(ActiveRecord::RecordInvalid) {
      Participant.create!(:experimental_session => experimental_sessions(:active))
    }
    assert_raise(ActiveRecord::RecordInvalid) {
      Participant.create!(:experimental_group => experimental_groups(:control))
    }
    assert_nothing_raised {
      Participant.create!(:experimental_session => experimental_sessions(:active),
                          :experimental_group => experimental_groups(:control))
    }
  end

  test "multiple participant creation" do
    p1 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:control))
    assert p1.save
    p2 = Participant.new(:experimental_session => experimental_sessions(:active),
                         :experimental_group => experimental_groups(:context_neutral))
    assert p2.save
    p3 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:experimental_one))
    assert p3.save
    p4 = Participant.new(:experimental_session => experimental_sessions(:active),
                         :experimental_group => experimental_groups(:experimental_two))
    assert p4.save
  end

  test "participant number uniqueness" do
    ps = Participant.create([{:experimental_session => experimental_sessions(:active),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:active),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:active),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:active),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)}])
    assert ps.length == 8
    ps.each do |p|
      assert_not_nil(p)
      assert p.valid?
    end
    participant_numbers = ps.collect { |p| p.participant_number }
    assert_equal(participant_numbers.sort.uniq, participant_numbers.sort)
  end

  test "find_active" do
    p1 = Participant.new(:experimental_session => experimental_sessions(:active),
                         :experimental_group => experimental_groups(:control))
    assert p1.save
    assert_not_nil(Participant.find_active(p1.participant_number))

    p2 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:control))
    assert p2.save
    assert_nil(Participant.find_active(p2.participant_number))
  end

  test "login and visit" do
    p = Participant.create(:experimental_session => experimental_sessions(:active),
                           :experimental_group => experimental_groups(:control))
    assert(p.valid?)
    assert_nil(p.first_login)
    assert_nil(p.last_access)
    assert_raise(ParticipantNotActive) { p.visit }
    assert_nothing_raised { p.login }
    assert_not_nil(p.first_login)
    assert_not_nil(p.last_access)
    assert_equal(p.first_login, p.last_access)
    assert_raise(ParticipantAlreadyActive) { p.login }
    assert_nothing_raised { p.visit }
    assert_not_equal(p.first_login, p.last_access)
  end
end
