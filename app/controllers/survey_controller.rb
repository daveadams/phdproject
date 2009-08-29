class SurveyController < ApplicationController
#  before_filter :check_phase
  skip_before_filter :check_session
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state
  skip_before_filter :establish_page_order
  skip_before_filter :log_page_load
  skip_before_filter :enforce_order

  def index
    # @questions = @participant.current_survey_page.questions
    @questions = Question.find(:all)
  end

  def complete
    # @participant.survey_complete = true
    # @participant.save
  end

 private
  def check_phase
    if @participant.survey_complete
      redirect_to(:controller => :complete)
    elsif not @participant.tutorial_complete
      redirect_to(:controller => :tutorial)
    elsif not @participant.experiment_complete
      redirect_to(:controller => :experiment)
    end
  end
end
