class SurveyPage < ActiveRecord::Base
  belongs_to :survey
  belongs_to :depends_on_answer, :class_name => "Answer"
  has_many :items, :class_name => "SurveyItem", :order => "sequence"
  has_many :questions, :through => :items
end
