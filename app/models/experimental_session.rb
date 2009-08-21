class ExperimentalSessionNotActive < ActiveRecord::ActiveRecordError; end
class ExperimentalSessionAlreadyActive < ActiveRecord::ActiveRecordError; end
class ExperimentalSessionAlreadyLockedDown < ActiveRecord::ActiveRecordError; end
class ExperimentalSessionAlreadyComplete < ActiveRecord::ActiveRecordError; end
class ExperimentalSessionUnused < ActiveRecord::ActiveRecordError; end

class ExperimentalSession < ActiveRecord::Base
  has_many :participants
  validates_uniqueness_of :name
  validates_presence_of :name

  def before_destroy
    if self.is_complete
      raise ExperimentalSessionAlreadyComplete
    end
    if self.is_active or self.current_participants.count > 0
      raise ExperimentalSessionAlreadyActive
    end

    self.participants.destroy_all
  end

  def self.active
    find_by_is_active(true)
  end

  def set_active
    raise ExperimentalSessionAlreadyComplete.new if self.is_complete
    raise ExperimentalSessionAlreadyActive.new if self.is_active

    self.is_active = true
    self.started_at = Time.now
    self.save!
  end

  def set_complete
    raise ExperimentalSessionNotActive.new unless self.is_active
    raise ExperimentalSessionAlreadyComplete.new if self.is_complete

    self.is_complete = true
    self.is_active = false
    self.ended_at = Time.now
    self.save!
  end

  def lockdown
    raise ExperimentalSessionAlreadyComplete.new if self.is_complete
    raise ExperimentalSessionNotActive.new unless self.is_active
    raise ExperimentalSessionAlreadyLockedDown.new if self.is_locked_down
    raise ExperimentalSessionUnused.new if self.current_participants.count < 1

    Participant.destroy(self.unseen_participants)
    self.is_locked_down = true
    self.save!
  end

  def create_participants(n, group)
    raise ExperimentalSessionAlreadyLockedDown.new if self.is_locked_down

    properties = {
      :experimental_session => self,
      :experimental_group => ExperimentalGroup.find(group)
    }
    spec = []
    n.times { spec << properties }

    Participant.create(spec)
  end

  def current_participants
    participants.reject { |p| p.last_access.nil? }
  end

  def unseen_participants
    participants.reject { |p| p.last_access? }
  end

  def phase_complete?
    participants.all? { |p| p["#{phase}_complete"] }
  end

  def round_complete?
    participants.all? { |p| p.round > round }
  end

  def next_phase
    raise ExperimentalSessionNotActive.new unless self.is_active

    if self.phase_complete?
      self.phase = case phase
                     when "tutorial" then "experiment"
                     when "experiment" then "survey"
                     when "survey" then "complete"
                   end
      self.save
    end
  end

  def next_round
    raise ExperimentalSessionNotActive.new unless self.is_active

    if phase == "experiment"
      round += 1
    end
  end

  def max_rounds
    if participants.count == 0
      0
    else
      round_counts = participants.collect { |p| p.experimental_group.rounds }
      round_counts[0] if round_counts.uniq.length == 1
    end
  end

 protected
  def validate
    errors.add_to_base("The number of rounds in the experimental groups of the participants in this session do not match.") if max_rounds.nil?

    if self.is_active
      validate_conditions = if self.id
                              ["is_active = ? and id != ?", true, self.id]
                            else
                              ["is_active = ?", true]
                            end
      if ExperimentalSession.count(:conditions => validate_conditions) > 0
        errors.add_to_base("Only one experimental session may be active at a time.")
      end
    end
  end
end
