class ExperimentalSession < ActiveRecord::Base
  belongs_to :experiment
  has_many :participants

  def is_active?
    Time.now >= starts_at and Time.now <= ends_at
  end

  def create_participants(n, group)
    properties = {
      :experimental_session => self,
      :experimental_group => ExperimentalGroup.find(group)
    }
    spec = []
    n.times { spec << properties }

    Participant.create(spec)
  end
end
