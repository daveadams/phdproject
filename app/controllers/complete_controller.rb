class CompleteController < ApplicationController
  skip_before_filter :establish_page_order
  before_filter :check_phase

  def index
    @participant.all_complete = true
    @participant.save

    if @participant.experimental_session.all_complete?
      @participant.experimental_session.set_complete
    end

    reset_session
  end

 private
  def check_phase
    if not @participant.tutorial_complete
      redirect_to(:controller => :tutorial)
    elsif not @participant.experiment_complete
      redirect_to(:controller => :experiment)
    elsif not @participant.survey_complete
      redirect_to(:controller => :survey)
    end
  end
end
