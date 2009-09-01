class TutorialController < ApplicationController
  before_filter :check_phase

  def index
    redirect_to(:action => @page_order[0])
  end

  def intro; end
  def overview; end

  def earnings_intro; end
  def earnings_task; end
  def earnings_report; end

  def tax_intro; end
  def tax_return; end

  def disclosure_intro; end
  def disclosure_report; end

  def audit_intro; end

  def audit_notify
    @message = ExperimentText.get_text(@participant, "check", "message")
  end

  def audit_ok; end
  def audit_error; end

  def doublecheck_intro; end

  def doublecheck_notify
    @message = ExperimentText.get_text(@participant, "check", "message")
  end

  def doublecheck_ok; end
  def doublecheck_error; end

  def completing; end

  def complete
    if request.post?
      @participant.tutorial_complete = true
      @participant.save
      redirect_to(:controller => :experiment)
    end
  end

 private
  def check_phase
    if @participant.survey_complete
      redirect_to(:controller => :complete)
    elsif @participant.experiment_complete
      redirect_to(:controller => :survey)
    elsif @participant.tutorial_complete
      redirect_to(:controller => :experiment)
    end
  end
end
