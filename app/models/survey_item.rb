class SurveyItem < ActiveRecord::Base
  belongs_to :survey_page
  belongs_to :question
end
