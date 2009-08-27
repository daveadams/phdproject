require 'test_helper'

class CashTransactionTest < ActiveSupport::TestCase
  test "validate type" do
    ct = CashTransaction.new(:participant_id => 1, :round => 1, :amount => 0.7)
    assert(!ct.valid?)
    ct.transaction_type = "what"
    assert(!ct.valid?)
    ct.transaction_type = ""
    assert(!ct.valid?)
    ct.transaction_type = "Tax"
    assert(!ct.valid?)
    ct.transaction_type = "myincome"
    assert(!ct.valid?)
    ct.transaction_type = "taxme"
    assert(!ct.valid?)

    %w( tax backtax penalty ).each do |t|
      ct.transaction_type = t
      ct.amount = -0.2
      assert(ct.valid?)
    end

    ct.amount = 0.7
    ct.transaction_type = "income"
    assert_nothing_raised { ct.save! }
  end

  test "ensure no duplicates" do
    assert_nothing_raised do
      CashTransaction.create! do |x|
        x.participant_id = 1
        x.round = 1
        x.amount = 0.7
        x.transaction_type = "income"
      end
    end

    assert_raise(ActiveRecord::RecordInvalid) do
      CashTransaction.create! do |x|
        x.participant_id = 1
        x.round = 1
        x.amount = 0.7
        x.transaction_type = "income"
      end
    end

    assert_nothing_raised do
      CashTransaction.create! do |x|
        x.participant_id = 1
        x.round = 1
        x.amount = -0.2
        x.transaction_type = "tax"
      end
    end
  end

  test "amount ranges" do
    ct = CashTransaction.new do |x|
      x.participant_id = 1
      x.round = 1
      x.amount = 0.7
      x.transaction_type = "tax"
    end

    assert(!ct.valid?)

    ct.amount = -0.2
    assert(ct.valid?)

    ct.transaction_type = "income"
    assert(!ct.valid?)

    ct.transaction_type = "backtax"
    assert(ct.valid?)

    ct.amount = 1.05
    assert(!ct.valid?)

    ct.transaction_type = "penalty"
    assert(!ct.valid?)

    ct.amount = -2.0
    assert(ct.valid?)
  end
end
