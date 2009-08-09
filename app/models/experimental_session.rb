class ExperimentalSession < ActiveRecord::Base
  belongs_to :experiment
  has_many :participants

  def is_active?
    Time.now >= starts_at and Time.now <= ends_at
  end
end
