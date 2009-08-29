class SurveyPage < ActiveRecord::Base
  belongs_to :survey
  belongs_to :depends_on_question, :class_name => "Question"
end
