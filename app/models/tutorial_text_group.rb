class TutorialTextGroup < ActiveRecord::Base
  has_many :experimental_groups
  has_many :tutorial_texts
end
