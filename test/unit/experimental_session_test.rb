require 'test_helper'

class ExperimentalSessionTest < ActiveSupport::TestCase
  test "new inactive" do
    x = ExperimentalSession.new(:name => "Test Inactive Session",
                                :starts_at => 3.days.ago.to_s(:db),
                                :ends_at => 2.days.ago.to_s(:db))
    assert !x.is_active?
  end

  test "new active" do
    x = ExperimentalSession.new(:name => "Test Active Session",
                                :starts_at => 1.days.ago.to_s(:db),
                                :ends_at => 1.days.from_now.to_s(:db))
    assert x.is_active?
  end
end
