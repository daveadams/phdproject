class SourceText < ActiveRecord::Base
  has_many :corrections
  validates_presence_of :errored_text, :round
  validates_uniqueness_of :round

  def evaluate_corrections(corrected_text)
    # OPTIMIZE - this isn't actually going to be 100% accurate
    self.corrections.collect do |c|
      if corrected_text.index(c.error).nil?
        if corrected_text.index(c.correction)
          [c.error, c.correction]
        end
      end
    end.compact
  end
end
