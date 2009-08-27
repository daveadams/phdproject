class SourceText < ActiveRecord::Base
  has_many :corrections
  validates_presence_of :errored_text, :round
  validates_uniqueness_of :round

  def evaluate_corrections(corrected_text)
    # CAREFUL
    # this works so long as the error and correction strings do
    # not otherwise appear in the errored or corrected text
    self.corrections.collect do |c|
      if corrected_text.index(c.error).nil?
        c if corrected_text.index(c.correction)
      end
    end.compact
  end
end
