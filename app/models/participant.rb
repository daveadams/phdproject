class Participant < ActiveRecord::Base
  belongs_to :experimental_session

  def self.find_active(partnum)
    result = self.find(:first, :conditions => ["participant_number = ?", partnum])
    unless result.nil? or not result.experimental_session.is_active?
      return result
    else
      return nil
    end
  end
end
