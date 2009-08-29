require 'test_helper'

class CorrectionCheckingTest < ActionController::IntegrationTest
  fixtures :all

  test "corrections" do
    0.upto 20 do |round|
      source = SourceText.find_by_round(round)
      correct = CorrectedText.find_by_round(round)

      assert_not_nil(source)
      assert_not_nil(correct)

      assert_not_nil(source.errored_text)
      assert_not_nil(correct.corrected_text)

      assert_equal(5, source.corrections.length)

      results = source.evaluate_corrections(correct.corrected_text)
      assert_equal(5, results.length)
    end
  end
end
