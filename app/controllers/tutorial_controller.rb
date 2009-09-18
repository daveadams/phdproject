class TutorialController < ApplicationController
  before_filter :check_phase

  def index
    redirect_to(:action => @page_order[0])
  end

  def intro; end
  def overview; end

  def earnings_intro; end

  def earnings_task
    @working_text = SourceText.find_by_round(0).errored_text
  end

  def check_work
    if request.post?
      @participant.tutorial_corrections.clear
      SourceText.find_by_round(0).
        evaluate_corrections(request[:working_text].squeeze(' ')).each do |c|
        begin
          @participant.tutorial_corrections << c
        rescue => e
          log_event(ActivityLog::ERROR, "Could not add tutorial_correction: #{e}")
        end
      end
      @participant.reload
      @participant.tutorial_cash = (@participant.tutorial_corrections.length *
                                    @participant.experimental_group.earnings)
      @participant.save
      redirect_to(:action => :earnings_report)
    else
      redirect_to(:action => :earnings_task)
    end
  end

  def earnings_report
    @fixes = @participant.tutorial_corrections.collect do |c|
      "<i>#{c.error}</i> was changed to <i>#{c.correction}</i>"
    end
    @total_earned = @participant.tutorial_cash
    @earnings_per_correction_label =
      ExperimentText.get_text(@participant, "earnings", "earnings_per_correction")
    @total_earned_label =
      ExperimentText.get_text(@participant, "earnings", "total_earned")
  end

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
    elsif @participant.phase2_complete
      redirect_to(:controller => :survey)
    elsif @participant.experiment_complete
      redirect_to(:controller => :phase2)
    elsif @participant.tutorial_complete
      redirect_to(:controller => :experiment)
    end
  end
end
