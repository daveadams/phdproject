class ExperimentalGroup < ActiveRecord::Base
  has_many :participants
  belongs_to :tutorial_text_group
end
