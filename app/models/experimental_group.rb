class ExperimentalGroup < ActiveRecord::Base
  has_many :participants
  belongs_to :tutorial_text_group
  validates_presence_of :name, :shortname
  validates_uniqueness_of :name, :shortname

  def rules
    { "earnings" => earnings,
      "tax_rate" => tax_rate,
      "penalty_rate" => penalty_rate,
      "rounds" => rounds }
  end

  def perform_audit?
    rand((1/self.audit_rate).to_i) == 0
  end
end
