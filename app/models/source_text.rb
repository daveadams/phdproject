class SourceText < ActiveRecord::Base
  has_many :corrections
  validates_presence_of :errored_text, :round
  validates_uniqueness_of :round

  def evaluate_corrections(corrected_text)
    self.corrections.collect do |c|
      if corrected_text.index(c.error_context || c.error).nil?
        c if corrected_text.index(c.correction_context || c.correction)
      end
    end.compact
  end
end
