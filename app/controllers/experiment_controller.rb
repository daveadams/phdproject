class ExperimentController < ApplicationController
  before_filter :check_round, :except => [:index, :wait]

  def index
    redirect_to(:action => :wait)
  end

  def wait
    if @participant.experimental_session.phase == "experiment" and
        @participant.experimental_session.round == @participant.round
      redirect_to(:action => :begin)
    else
      @display_bank = true
      render :action => :wait, :layout => false
    end
  end

  def begin
    @page_title = "Begin Round #{@participant.round}"
    @display_bank = true
  end

  def work
    @page_title = "Earnings Task"
    @working_text = SourceText.find_by_round(@participant.round).errored_text

    # TODO: autotimer
  end

  def check_work
    # TODO: check timing, too
    if request.post?
      SourceText.find_by_round(@participant.round).
        evaluate_corrections(request[:working_text]).each do |c|
        begin
          cc = CorrectCorrection.create!(:participant_id => @participant.id,
                                         :round => @participant.round,
                                         :correction_id => c.id)
          @participant.correct_corrections << cc
        rescue => e
          log_event(ActivityLog::ERROR, "Could not add correct_correction: #{e}")
        end
      end
      @participant.reload

      begin
        earnings = (@participant.correct_corrections_for_current_round.length *
                    @participant.experimental_group.earnings)
        @participant.earn_income(earnings)
      rescue ActiveRecord::RecordInvalid => e
        log_event(ActivityLog::OUT_OF_SEQUENCE, "Failed to earn_income: round #{@participant.round}, $#{earnings}: #{e}")
      end

      redirect_to(:action => :earnings)
    else
      redirect_to(:action => :work)
    end
  end

  def earnings
    @page_title = "Earnings Report"
    @display_bank = true

    @fixes = @participant.correct_corrections_for_current_round.
        collect { |c| "<i>#{c.correction.error}</i> was changed to <i>#{c.correction.correction}</i>" }

    @total_earned = @participant.income_for_current_round || 0.0
  end

  def message
    if @message = @participant.experimental_group.message
      render :layout => false
    else
      redirect_to(:action => :report)
    end
  end

  def report
    # TODO: page title based on group
    @page_title = "Individual Income Tax Return"
    # TODO: form labels based on group
    @reported_earnings_label = "Reported Income"
    @tax_rate_label = "Tax Rate"
    @estimate_button_label = "Estimate Taxes"
    @amount_due_label = "Tax Due"
    @report_earnings_button_label = "Report Earnings"
  end

  def check
    # TODO: select if this person gets audited or not
    @page_title = "Notification"

    # TODO: message based on group
    @notification = "Your Individual Income Tax Return has been selected for audit. Please proceed to the audit report to see the results of the audit."

    render :layout => false
  end

  def results
    # TODO: title based on group
    @page_title = "Audit Report"
    @display_bank = true

    # TODO: labels based on group
    @earnings_label = "Earned Income"
    @reported_label = "Reported Income"
    @tax_rate_label = "Tax Rate"
    @additional_label = "Additional Tax Due"

    # TODO: set results_ok based on actual results
    @results_ok = false

    # TODO: need a way to keep track of current earnings data (session?)
    @earned = 1.05
    @reported = 0.8
    @difference = 0.25
    @additional = 0.05
    @penalties = 0.07
    @total = 0.12

    # TODO: set message based on group
    @message = "You owe $#{@total} in penalties and unpaid taxes. This amount has been subtracted from your bank."
  end

  def end_round
    if @participant.round >= @participant.experimental_group.rounds
      redirect_to(:action => :complete)
    else
      @participant.round += 1
      @participant.save
      redirect_to(:action => :wait)
    end
  end

  def complete
    if request.post?
      @participant.experiment_complete = true
      @participant.save

      redirect_to(:controller => "survey")
    else
      @page_title = "Work Complete"
      @display_bank = true
    end
  end

 private
  def check_round
    if @participant.round > @participant.experimental_session.round
      log_event(ActivityLog::OUT_OF_SEQUENCE, "Redirecting to /experiment/wait")
      redirect_to(:action => :wait)
    end
  end
end
