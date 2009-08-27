require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  test "new participant" do
    p = Participant.new
    p.experimental_session = experimental_sessions(:inactive)
    p.experimental_group = experimental_groups(:experimental_one)

    assert(p.valid?)
    assert(p.save)

    assert_not_nil(p.participant_number)
    assert_equal(p.experimental_session, experimental_sessions(:inactive))
    assert_equal(p.experimental_group, experimental_groups(:experimental_one))
    assert_equal(p.is_active, false)
    assert_equal(p.cash, 0)
    assert_equal(p.round, 1)
    assert_nil(p.phase)
    assert_nil(p.page)
  end

  test "new participant with args" do
    p = Participant.new(:experimental_session => experimental_sessions(:inactive),
                        :experimental_group => experimental_groups(:experimental_two))
    assert(p.valid?)
    assert(p.save)

    assert_not_nil(p.participant_number)
    assert_equal(p.experimental_session, experimental_sessions(:inactive))
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
      Participant.create!(:experimental_session => experimental_sessions(:inactive))
    }
    assert_raise(ActiveRecord::RecordInvalid) {
      Participant.create!(:experimental_group => experimental_groups(:control))
    }
    assert_nothing_raised {
      Participant.create!(:experimental_session => experimental_sessions(:inactive),
                          :experimental_group => experimental_groups(:control))
    }
  end

  test "multiple participant creation" do
    p1 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:control))
    assert p1.save
    p2 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:context_neutral))
    assert p2.save
    p3 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:experimental_one))
    assert p3.save
    p4 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:experimental_two))
    assert p4.save
  end

  test "participant number uniqueness" do
    ps = Participant.create([{:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
                               :experimental_group => experimental_groups(:control)},
                             {:experimental_session => experimental_sessions(:inactive),
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
    xs = ExperimentalSession.new(:name => "Active Testing")
    assert(xs.save)
    assert_nothing_raised { xs.set_active }

    p1 = Participant.new(:experimental_session => xs,
                         :experimental_group => experimental_groups(:control))
    assert p1.save
    assert_not_nil(Participant.find_active(p1.participant_number))

    p2 = Participant.new(:experimental_session => experimental_sessions(:inactive),
                         :experimental_group => experimental_groups(:control))
    assert p2.save
    assert_nil(Participant.find_active(p2.participant_number))
  end

  test "login" do
    p = Participant.create(:experimental_session => experimental_sessions(:inactive),
                           :experimental_group => experimental_groups(:control))
    assert(p.valid?)
    assert_nil(p.first_login)
    assert_nil(p.last_access)
    assert_nothing_raised { p.login }
    assert_not_nil(p.first_login)
    assert_not_nil(p.last_access)
    assert_equal(p.first_login, p.last_access)
    assert_raise(ParticipantAlreadyActive) { p.login }
  end

  test "participant cash" do
    p = Participant.create(:experimental_session => experimental_sessions(:inactive),
                           :experimental_group => experimental_groups(:control))
    assert_equal(1, p.round)
    assert_equal([], p.cash_transactions)
    assert_equal(0.0, p.cash)
    assert_equal(0, p.activity_logs.length)

    assert_nothing_raised { p.earn_income(0.5) }
    assert_equal(1, p.cash_transactions.length)
    assert_equal(0.5, p.cash)
    assert_equal(1, p.activity_logs.length)

    assert_raise(ActiveRecord::RecordInvalid) { p.earn_income(0.1) }
    assert_equal(1, p.cash_transactions.length)
    assert_equal(0.5, p.cash)
    assert_equal(1, p.activity_logs.length)

    assert_nothing_raised { p.pay_tax(-0.2) }
    assert_equal(2, p.cash_transactions.length)
    assert_equal(0.3, p.cash)
    assert_equal(2, p.activity_logs.length)

    p.round += 1
    assert_nothing_raised { p.save! }
    assert_equal(2, p.round)

    assert_raise(ActiveRecord::RecordInvalid) { p.earn_income(-0.1) }
    assert_raise(ActiveRecord::RecordInvalid) { p.earn_income(-1.2) }
    assert_nothing_raised { p.earn_income(0.0) }

    assert_equal(3, p.cash_transactions.length)
    assert_equal(0.3, p.cash)
    assert_equal(3, p.activity_logs.length)

    assert_raise(ActiveRecord::RecordInvalid) { p.pay_tax(0.5) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_tax(0.01) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_tax(2.77) }
    assert_nothing_raised { p.pay_tax(0.0) }

    assert_equal(4, p.cash_transactions.length)
    assert_equal(0.3, p.cash)
    assert_equal(4, p.activity_logs.length)

    p.round += 1
    assert_nothing_raised { p.save! }
    assert_equal(3, p.round)

    assert_nothing_raised { p.earn_income(1.75) }
    assert_equal(5, p.cash_transactions.length)
    assert_equal(2.05, p.cash)
    assert_equal(5, p.activity_logs.length)

    assert_nothing_raised { p.pay_tax(-0.25) }
    assert_equal(6, p.cash_transactions.length)
    assert_equal(1.8, p.cash)
    assert_equal(6, p.activity_logs.length)

    assert_raise(ActiveRecord::RecordInvalid) { p.pay_backtax(0.1) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_backtax(1.0) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_backtax(0.46) }

    assert_nothing_raised { p.pay_backtax(-0.1) }
    assert_equal(7, p.cash_transactions.length)
    assert_equal(1.7, p.cash)
    assert_equal(7, p.activity_logs.length)

    assert_raise(ActiveRecord::RecordInvalid) { p.pay_penalty(0.01) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_penalty(3.77) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_penalty(0.98) }

    assert_nothing_raised { p.pay_penalty(-0.15) }
    assert_equal(8, p.cash_transactions.length)
    assert_equal(1.55, p.cash)
    assert_equal(8, p.activity_logs.length)

    assert_raise(ActiveRecord::RecordInvalid) { p.earn_income(0.1) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_tax(-0.1) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_backtax(-0.1) }
    assert_raise(ActiveRecord::RecordInvalid) { p.pay_penalty(-0.1) }

    assert_equal(8, p.cash_transactions.length)
    assert_equal(8, p.activity_logs.length)
    assert_equal(1, p.activity_logs.collect { |log| log.event }.uniq.length)
    assert_equal(ActivityLog::CASH_TRANSACTION,
                 p.activity_logs.collect { |log| log.event }.uniq.first)
  end
end
