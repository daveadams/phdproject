class SurveyPage < ActiveRecord::Base
  belongs_to :survey
  belongs_to :depends_on_answer, :class_name => "Answer"
  has_many :questions, :through => :survey_items, :order => "sequence"
end
