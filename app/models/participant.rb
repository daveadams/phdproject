class ParticipantAlreadyActive < ActiveRecord::ActiveRecordError; end
class ParticipantNotActive < ActiveRecord::ActiveRecordError; end

class Participant < ActiveRecord::Base
  belongs_to :experimental_session
  belongs_to :experimental_group
  has_many :activity_logs

  validates_presence_of :participant_number
  validates_uniqueness_of :participant_number
  validates_presence_of :experimental_session_id
  validates_presence_of :experimental_group_id

  def self.find_active(partnum)
    result = self.find(:first, :conditions => ["participant_number = ?", partnum])
    unless result.nil? or not result.experimental_session.is_active
      return result
    else
      return nil
    end
  end

  def initialize(fields = nil)
    fields ||= {}
    fields[:participant_number] = Participant.generate_participant_number
    fields[:is_active] = false
    super(fields)
  end

  def login
    raise ParticipantAlreadyActive if self.is_active

    self.first_login ||= Time.now
    self.last_access = self.first_login
    self.is_active = true
    self.save
  end

 private
  def self.generate_potential_participant_number
    alphaset = ("A".."Z").to_a
    ppn = ""
    2.times { ppn << alphaset[rand(alphaset.length - 1)] }
    4.times { ppn << rand(9).to_s }
    return ppn
  end

  def self.generate_participant_number
    pn = generate_potential_participant_number
    while Participant.find_by_participant_number(pn) != nil
      pn = generate_potential_participant_number
    end
    return pn
  end
end
