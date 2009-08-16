class ExperimentalGroup < ActiveRecord::Base
  has_many :participants
  belongs_to :tutorial_text_group

  def rules
    { "earnings" => earnings,
      "tax_rate" => tax_rate,
      "penalty_rate" => penalty_rate,
      "rounds" => rounds }
  end
end
