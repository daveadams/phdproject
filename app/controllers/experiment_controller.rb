class ExperimentController < ApplicationController
  before_filter :check_phase
  before_filter :check_round, :except => [:index, :wait]
  skip_before_filter :log_page_load, :only => [:estimate, :seconds_remaining]

  def index
    redirect_to(:action => :wait)
  end

  def wait
    if @participant.experimental_session.phase == "experiment" and
        @participant.experimental_session.round == @participant.round
      redirect_to(:action => :begin)
    else
      if @participant.experimental_session.phase == "tutorial" and
          @participant.experimental_session.phase_complete?
        @participant.experimental_session.next_phase
        redirect_to(:action => :wait)
      elsif @participant.experimental_session.phase == "experiment" and
          @participant.experimental_session.round_complete?
        @participant.experimental_session.next_round
        redirect_to(:action => :wait)
      else
        @display_bank = true
        render :action => :wait, :layout => false
      end
    end
  end

  def begin
    if @participant.checked_for_current_round?
      if @participant.audit_pending_for_current_round?
        redirect_to(:action => :check)
      else
        redirect_to(:action => :end_round)
      end
    elsif @participant.taxes_paid_for_current_round?
      redirect_to(:action => :check)
    elsif @participant.work_complete_for_current_round?
      redirect_to(:action => :earnings)
    else
      @page_title = "Begin Round #{@participant.round}"
      @display_bank = true
    end
  end

  def work
    if @participant.work_complete_for_current_round?
      redirect_to(:action => :message)
    else
      @page_title = "Earnings Task"
      @working_text = SourceText.find_by_round(@participant.round).errored_text
      @seconds_remaining = work_time_remaining
    end
  end

  def seconds_remaining
    render :text => work_time_remaining.to_s
  end

  def check_work
    if @participant.work_complete_for_current_round?
      if not @participant.taxes_paid_for_current_round?
        redirect_to(:action => :message)
      else
        redirect_to(:action => :check)
      end
    else
      if request.post?
        SourceText.find_by_round(@participant.round).
          evaluate_corrections((request[:working_text] || "").squeeze(' ')).each do |c|
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
    if not @participant.work_complete_for_current_round?
      redirect_to(:action => :work)
    else
      if @participant.taxes_paid_for_current_round?
        redirect_to(:action => :check)
      end
    end
  end

  def submit_report
    if request.post?
      if @participant.taxes_paid_for_current_round?
        log_event(ActivityLog::OUT_OF_SEQUENCE,
                  "Taxes already paid. Cannot submit a new report.")
        redirect_to(:action => :check)
      else
        if request[:reported_earnings].nil? or request[:reported_earnings].strip == ""
          flash[:error] = "You must enter some value."
          log_event(ActivityLog::ERROR, "Reported earnings was empty.")
          redirect_to(:action => :report)
        else
          max_possible_earnings = (@participant.experimental_group.earnings * 5)
          reported_earnings = request[:reported_earnings].to_f
          if reported_earnings < 0
            flash[:error] = "Cannot be less than zero."
            log_event(ActivityLog::ERROR, "Reported earnings was negative.")
            redirect_to(:action => :report)
          elsif reported_earnings > @participant.income_for_current_round
            flash[:error] = "Invalid entry."
            log_event(ActivityLog::ERROR, "Reported earnings was greater than actual earnings.")
            redirect_to(:action => :report)
          else
            @participant.report_earnings(reported_earnings)
            tax_due = -(reported_earnings * (@participant.experimental_group.tax_rate.to_f/100))

            begin
              @participant.pay_tax(tax_due)
            rescue ActiveRecord::RecordInvalid => e
              log_event(ActivityLog::OUT_OF_SEQUENCE, "Could not add tax payment: #{e}")
            end
            redirect_to(:action => :check)
          end
        end
      end
    else
      redirect_to(:action => :report)
    end
  end

  def check
    if @participant.checked_for_current_round?
      if @participant.audit_pending_for_current_round?
        render :layout => false
      else
        if @participant.audit_completed
          redirect_to(:action => :results)
        else
          redirect_to(:action => :end_round)
        end
      end
    else
      @participant.last_check = @participant.round
      @participant.save

      if @participant.perform_audit?
        @participant.to_be_audited = true
        @participant.save

        render :layout => false
      else
        redirect_to(:action => :end_round)
      end
    end
  end

  def perform_check
    if @participant.checked_for_current_round?
      if @participant.audit_pending_for_current_round?
        log_event(ActivityLog::AUDIT, "Auditing participant")
        @participant.audit
        redirect_to(:action => :results)
      else
        if @participant.audit_completed
          redirect_to(:action => :results)
        else
          redirect_to(:action => :end_round)
        end
      end
    else
      redirect_to(:action => :check)
    end
  end

  def results
    if not @participant.audit_completed
      redirect_to(:action => :check)
    else
      @display_bank = true

      @earned = @participant.income_for_current_round
      @reported = @participant.reported_earnings_for_current_round
      @difference = @earned - @reported
      @results_ok = (@difference == 0.0)
      @additional = -@participant.backtax_for_current_round
      @penalties = -@participant.penalty_for_current_round
      @total = @additional + @penalties
    end
  end

  def end_round
    if not @participant.work_complete_for_current_round?
      redirect_to(:action => :work)
    elsif not @participant.taxes_paid_for_current_round?
      redirect_to(:action => :message)
    elsif not @participant.checked_for_current_round?
      redirect_to(:action => :check)
    elsif @participant.audit_pending_for_current_round?
      redirect_to(:action => :check)
    else
      if @participant.round >= @participant.experimental_group.rounds
        @participant.advance_round
        redirect_to(:action => :complete)
      else
        unless @participant.experimental_session.round < @participant.round
          @participant.advance_round
        end
        redirect_to(:action => :wait)
      end
    end
  end

  def complete
    if @participant.round < @participant.experimental_group.rounds
      redirect_to(:action => :wait)
    else
      if @participant.round > @participant.experimental_group.rounds
        if request.post?
          @participant.experiment_complete = true
          @participant.save

          redirect_to(:controller => :phase2)
        else
          @page_title = "Please Wait..."
          @display_bank = true
          render :layout => false
        end
      else
        redirect_to(:action => :wait)
      end
    end
  end

  def estimate
    if request.xhr?
      log_event(ActivityLog::ESTIMATE, "Submitted for estimate: '#{request[:estimate]}'")
      render :text => "OK"
    else
      redirect_to(:action => :report)
    end
  end

 private
  def check_round
    if @participant.round > @participant.experimental_session.round and
        @participant.round <= @participant.experimental_group.rounds
      log_event(ActivityLog::OUT_OF_SEQUENCE, "Redirecting to /experiment/wait")
      redirect_to(:action => :wait)
    end
  end

  def check_phase
    if @participant.survey_complete
      redirect_to(:controller => :complete)
    elsif @participant.phase2_complete
      redirect_to(:controller => :survey)
    elsif @participant.experiment_complete
      redirect_to(:controller => :phase2)
    elsif not @participant.tutorial_complete
      redirect_to(:controller => :tutorial)
    end
  end

  def work_time_remaining
    current_time = Time.now
    if @participant.work_load_time.nil?
      @participant.work_load_time = current_time
      @participant.save
    end
    [@participant.experimental_group.work_time_limit -
     (current_time - @participant.work_load_time).to_i, 0].max
  end
end
