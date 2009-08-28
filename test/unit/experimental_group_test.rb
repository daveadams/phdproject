require 'test_helper'

class ExperimentalGroupTest < ActiveSupport::TestCase
  test "audit rate default" do
    assert_equal(0.01, experimental_groups(:control).audit_rate.to_f)
    assert_equal(0.01, experimental_groups(:context_neutral).audit_rate.to_f)
    assert_equal(0.01, experimental_groups(:experimental_one).audit_rate.to_f)
    assert_equal(0.01, experimental_groups(:experimental_two).audit_rate.to_f)

    xg = nil
    assert_nothing_raised do
      xg = ExperimentalGroup.create!(:name => "Inside Test", :shortname => "it")
    end
    xg.reload
    assert_equal(0.01, xg.audit_rate.to_f)
  end

  test "audit rate" do
    xg = nil
    assert_nothing_raised do
      xg = ExperimentalGroup.create!(:name => "Rate Test",
                                     :shortname => "rt",
                                     :audit_rate => 0.5)
    end

    # hard to test this
    counter = 0
    1000.times do
      counter += 1 if xg.perform_audit?
    end
    assert(counter > 0)
    assert(counter < 1000)
  end
end
