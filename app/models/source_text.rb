class SourceText < ActiveRecord::Base
  has_many :corrections
  validates_presence_of :errored_text, :round
  validates_uniqueness_of :round

  def evaluate_corrections(corrected_text)
    # TODO: return an array of correct corrections made as tuples: error string, correction string
    [["x","y"],["z","Z"]]
  end
end
