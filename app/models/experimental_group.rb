class ExperimentalGroup < ActiveRecord::Base
  has_many :participants
  belongs_to :tutorial_text_group
  belongs_to :survey

  validates_presence_of :name, :shortname
  validates_uniqueness_of :name, :shortname

  def rules
    { "earnings" => earnings,
      "tax_rate" => tax_rate,
      "penalty_rate" => penalty_rate,
      "rounds" => rounds }
  end
end
