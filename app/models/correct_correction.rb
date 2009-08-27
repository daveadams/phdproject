class CorrectCorrection < ActiveRecord::Base
  belongs_to :participant
  belongs_to :correction

  validates_associated :participant
  validates_presence_of :round
  validates_associated :correction

  validates_uniqueness_of :round, :scope => [:participant_id, :correction_id]
end
