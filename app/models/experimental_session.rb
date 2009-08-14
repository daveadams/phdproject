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
end
