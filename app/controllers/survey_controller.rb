class SurveyController < ApplicationController
  def index
  end

  def complete
    @participant.survey_complete = true
    @participant.save
  end
end
