class AdminController < ApplicationController
  skip_before_filter :check_session
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state
  skip_before_filter :establish_page_order
  skip_before_filter :log_page_load
  skip_before_filter :enforce_order

  def sessions
    @page_title = "Experimental Sessions"

    @active_session = ExperimentalSession.active
    @sessions = ExperimentalSession.find(:all,
                                         :order => "is_complete, was_forced") - [@active_session]
    @groups = ExperimentalGroup.find(:all)
  end

  def activate_session
    if request.post?
      unless ExperimentalSession.active.nil?
        flash[:error] = "Another session is already active."
      else
        begin
          xs = ExperimentalSession.find(request[:id])
          xs.set_active
        rescue ActiveRecord::RecordNotFound
          flash[:error] = "Could not find that experimental session."
        rescue ExperimentalSessionAlreadyActive
          flash[:error] = "That experimental session is already active."
        rescue ExperimentalSessionAlreadyComplete
          flash[:error] = "That experimental session is already complete."
        end
      end
      if flash[:error]
        redirect_to(:action => :sessions)
        return
      else
        redirect_to(:action => :status)
        return
      end
    else
      redirect_to(:action => :sessions)
      return
    end
  end

  def add_session
    if request.post?
      xs = ExperimentalSession.new(:name => request['name'],
                                   :is_active => false)
      if xs.save
        flash[:highlight] = "row#{xs.id}"
      else
        flash[:error] = xs.errors.full_messages.join("<br />")
      end
    end
    redirect_to(:action => :sessions)
  end

  def delete_session
    if request.post?
      begin
        ExperimentalSession.find(request[:id]).destroy
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Could not find that experimental session."
      rescue ExperimentalSessionAlreadyActive
        flash[:error] = "Could not delete that experimental session because it is active."
      rescue ExperimentalSessionAlreadyComplete
        flash[:error] = "Could not delete that experimental session because it is complete."
      end
    end
    redirect_to(:action => :sessions)
  end

  def add_participants
    @page_title = "Add Participants"

    begin
      @session = ExperimentalSession.find(request[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Could not find that experimental session."
      redirect_to(:action => :sessions)
      return
    end

    @return_action = request[:return_to] ||
      ((ExperimentalSession.active == @session) ? :status : :sessions)

    def redirect_back
      logger.info "DAVE: inside redirect_back: return action is #{@return_action}"
      if @return_action == :status || @return_action == :sessions
        redirect_to(:action => @return_action)
        return
      else
        redirect_to(:action => @return_action, :id => request[:id])
        return
      end
    end

    if @session.is_locked_down
      flash[:error] = "Can't add participants to a locked-down session."
      redirect_back
      return
    end

    if @session.is_complete
      flash[:error] = "Can't add participants to a completed session."
      redirect_back
      return
    end

    if request.post?
      n = request[:n].nil? ? nil : request[:n].to_i
      if n.nil?
        flash[:error] = "You must provide a number of participants to create."
        redirect_to(:action => :add_participants, :id => @session.id)
        return
      elsif request[:experimental_group_id].nil?
        flash[:error] = "Please select an experimental group."
        redirect_to(:action => :add_participants, :id => @session.id)
        return
      elsif n <= 0
        flash[:error] = "Please specify a number greater than zero."
        redirect_to(:action => :add_participants, :id => @session.id)
        return
      elsif n > 100
        flash[:error] = "Cannot create more than 100 participants at once."
        redirect_to(:action => :add_participants, :id => @session.id)
        return
      else
        begin
          @group = ExperimentalGroup.find(request[:experimental_group_id].to_i)
          @session.create_participants(n, @group.id)
          flash[:highlight] = "#{@group.shortname}#{@session.id}"
          redirect_back
          return
        rescue ActiveRecord::RecordNotFound
          flash[:error] = "Invalid experimental group selected."
          redirect_to(:action => :add_participants, :id => @session.id)
          return
        rescue => e
          flash[:error] = "An unexpected error occured when trying to add the participants: #{e}"
          redirect_to(:action => :add_participants, :id => @session.id)
          return
        end
      end
    else
      @groups = ExperimentalGroup.all
      render :layout => false if request.xhr?
    end
  end

  def lockdown
    if request.post?
      begin
        xs = ExperimentalSession.find(request[:id])
        xs.lockdown
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Could not find that experimental session."
      rescue ExperimentalSessionNotActive
        flash[:error] = "That experimental session is not active."
      rescue ExperimentalSessionAlreadyComplete
        flash[:error] = "That experimental session is already complete."
      rescue ExperimentalSessionUnused
        flash[:error] = "Can't lock down a session with no active participants."
      rescue ExperimentalSessionAlreadyLockedDown
        # nothing to do
      end
    end
    redirect_to(:action => :status)
  end

  def begin_experiment
    return_action = :status

    if request.post?
      begin
        xs = ExperimentalSession.find(request[:id])
        if !xs.is_active
          flash[:error] = "This session is not active."
          return_action = :sessions
        elsif !xs.is_locked_down
          flash[:error] = "This session is not yet locked down."
        elsif xs.is_complete
          flash[:error] = "This session is already complete."
          return_action = :sessions
        elsif xs.current_participants.count < 1
          flash[:error] = "Can't start the experiment with no active participants."
        elsif xs.phase != "tutorial"
          flash[:error] = "This session is no longer in the tutorial phase."
        elsif !xs.phase_complete?
          flash[:error] = "Not all participants are done with the tutorial."
        else
          xs.next_phase
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Could not find that experimental session."
        return_action = :sessions
      rescue ExperimentalSessionNotActive
        flash[:error] = "This session is not active."
        return_action = :sessions
      end
    end

    redirect_to(:action => return_action)
  end

  def advance_round
    return_action = :status

    if request.post?
      begin
        xs = ExperimentalSession.find(request[:id])
        if xs.current_participants.count < 1
          flash[:error] = "Can't start the experiment with no active participants."
        elsif !xs.round_complete?
          flash[:error] = "Not all participants are done with the round."
        else
          xs.next_round
          flash[:highlight] = "current-round"
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Could not find that experimental session."
        return_action = :sessions
      rescue ExperimentalSessionNotActive
        flash[:error] = "This session is not active."
        return_action = :sessions
      rescue ExperimentalSessionMaxRounds
        flash[:error] = "There are no more rounds."
      rescue ExperimentalSessionNotInExperiment
        flash[:error] = "The current phase does not allow advancing rounds."
      end
    end

    redirect_to(:action => return_action)
  end

  def force_close
    if ExperimentalSession.active.nil?
      flash[:error] = "Could not find that experimental session."
    else
      begin
        ExperimentalSession.active.set_complete(!ExperimentalSession.active.all_complete?)
      rescue => e
        flash[:error] = "An error occurred when closing that session: #{e}"
      end
    end
    redirect_to(:action => :sessions)
  end

  def checkout
    begin
      @participant = Participant.find(request[:id])
      if @participant.paid_at? or not @participant.all_complete
        flash[:error] = "Already checked out."
        redirect_to(:action => :participant, :id => @participant.id)
        return
      end
      @page_title = "Checkout: #{@participant.participant_number}"
    rescue
      flash[:error] = "Could not find that participant."
      redirect_to(:action => :sessions)
      return
    end
  end

  def mark_paid
    begin
      @participant = Participant.find(request[:id])
      unless @participant.paid_at
        @participant.paid_at = Time.now
        @participant.save
      end
      redirect_to(:action => :participant, :id => @participant.id)
      return
    rescue
      flash[:error] = "Could not find that participant."
      redirect_to(:action => :sessions)
      return
    end
  end

  def force_participant_complete
    begin
      @participant = Participant.find(request[:id])
      if not @participant.all_complete
        @participant.was_forced = true
      end
      @participant.tutorial_complete = true
      @participant.experiment_complete = true
      @participant.survey_complete = true
      @participant.all_complete = true
      @participant.round = @participant.experimental_group.rounds + 1
      @participant.is_active = false
      @participant.save
      redirect_to(:action => :participant, :id => @participant.id)
      return
    rescue
      flash[:error] = "Could not find that participant."
      redirect_to(:action => :sessions)
      return
    end
  end

  def reset_browser_session
    begin
      @participant = Participant.find(request[:id])
      @participant.is_active = false
      @participant.save
      redirect_to(:action => :participant, :id => @participant.id)
      return
    rescue
      flash[:error] = "Could not find that participant."
      redirect_to(:action => :sessions)
      return
    end
  end

  def print
    @page_title = "Print Participant Numbers"

    begin
      @session = ExperimentalSession.find(request[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Could not find that experimental session."
      redirect_to(:action => :sessions)
      return
    end

    render :layout => false
  end

  def status
    @page_title = "Current Status"
    @active_session = ExperimentalSession.active
    errored = false

    if @active_session.nil?
      flash[:error] = "Could not find that experimental session."
      errored = true
    elsif @active_session.is_complete
      flash[:error] = "That experimental session is already complete."
      errored = true
    elsif !@active_session.is_active
      flash[:error] = "That experimental session is not active."
      errored = true
    end

    if errored
      redirect_to(:action => :sessions)
      return
    end

    if request.xhr?
      render(:partial => "participant_table",
             :locals => { :this_session => @active_session } )
    end
  end

  def session_info
    begin
      @experimental_session = ExperimentalSession.find(request[:id])
      if ExperimentalSession.active and
          ExperimentalSession.active.id == @experimental_session.id
        redirect_to(:action => :status)
        return
      else
        @page_title = "Session Detail: #{@experimental_session.name}"
      end
    rescue
      flash[:error] = "Could not find that session."
      redirect_to(:action => :sessions)
      return
    end
  end

  def session_report
#    begin
      xs = ExperimentalSession.find(request[:id])
      send_data(xs.report_csv, :type => "text/csv",
                :filename => xs.name.gsub(/[^0-9A-Za-z\-.]/,'-') + ".csv")
#    rescue
#      render(:text => "An error occured. Please contact the administrator.",
#             :status => 404)
#    end
  end

  def full_report
    report_data = ""

    ExperimentalSession.find(:all, :order => "started_at").each do |xs|
      next unless xs.is_complete
      next if xs.name =~ /Test/i
      report_data += xs.report_csv
    end

    send_data(report_data, :type => "text/csv",
              :filename => "full-report.csv")
  end

  def participant
    begin
      if request[:participant_number]
        @participant = Participant.find_by_participant_number(request[:participant_number])
        raise if @participant.nil?
      else
        @participant = Participant.find(request[:id])
      end
      @page_title = "Participant Detail: #{@participant.participant_number}"
    rescue
      flash[:error] = "Could not find that participant."
      redirect_to(:action => :sessions)
      return
    end
  end

  def participant_activity_log
    if !request.xhr?
      redirect_to(:action => :sessions)
      return
    else
      begin
        @participant = Participant.find(request[:id])
        @activity = @participant.activity_logs.sort_by { |log| log.created_at }
        render :layout => false
      rescue
        render :text => "ERROR: Could not find participant."
      end
    end
  end

  def participant_round_history
    if !request.xhr?
      redirect_to(:action => :sessions)
      return
    else
      begin
        @participant = Participant.find(request[:id])
      rescue
        render :text => "ERROR: Could not find participant."
      end

      @earnings_history = @participant.earnings_history
      @reporting_history = @participant.reporting_history
      @tax_paid_history = @participant.tax_paid_history
      @backtax_history = @participant.backtax_history
      @penalty_history = @participant.penalty_history
      @audit_history = @participant.audit_history.collect { |ah| ah ? "Yes" : "No" }
    end
  end
end
