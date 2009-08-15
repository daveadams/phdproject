class ExperimentalSession < ActiveRecord::Base
  belongs_to :experiment
  has_many :participants

  def create_participants(n, group)
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
end
