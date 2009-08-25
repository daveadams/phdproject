class SourceText < ActiveRecord::Base
  has_many :corrections

  def evaluate_corrections(corrected_text)
    # TODO: return an array of correct corrections made as tuples: error string, correction string
    [["x","y"],["z","Z"]]
  end
end
