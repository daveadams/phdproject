class AdminController < ApplicationController
  skip_before_filter :check_session
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state
  skip_before_filter :establish_page_order
  skip_before_filter :log_page_load
  skip_before_filter :enforce_order

  def participants
    @participants = Participant.find(:all)
  end

  def sessions
    @page_title = "Experimental Sessions"

    @active_session = ExperimentalSession.active
    @sessions = ExperimentalSession.find(:all) - [@active_session]
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
    end
    redirect_to(:action => :sessions)
  end

  def add_session
    if request.post?
      xs = ExperimentalSession.new(:name => request['name'],
                                   :is_active => false)
      unless xs.save
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
    end

    if @session.is_locked_down
      flash[:error] = "Can't add participants to a locked-down session."
      redirect_to(:action => :sessions)
    end

    if @session.is_complete
      flash[:error] = "Can't add participants to a completed session."
      redirect_to(:action => :sessions)
    end

    if request.post?
      n = request[:n].nil? ? nil : request[:n].to_i
      if n.nil?
        flash[:error] = "You must provide a number of participants to create."
        redirect_to(:action => :add_participants, :id => @session.id)
      elsif request[:experimental_group_id].nil?
        flash[:error] = "Please select an experimental group."
        redirect_to(:action => :add_participants, :id => @session.id)
      elsif n <= 0
        flash[:error] = "Please specify a number greater than zero."
        redirect_to(:action => :add_participants, :id => @session.id)
      elsif n > 100
        flash[:error] = "Cannot create more than 100 participants at once."
        redirect_to(:action => :add_participants, :id => @session.id)
      else
        begin
          @group = ExperimentalGroup.find(request[:experimental_group_id].to_i)
          @session.create_participants(n, @group.id)
          redirect_to(:action => :sessions)
        rescue ActiveRecord::RecordNotFound
          flash[:error] = "Invalid experimental group selected."
          redirect_to(:action => :add_participants, :id => @session.id)
        rescue => e
          flash[:error] = "An unexpected error occured when trying to add the participants: #{e}"
          redirect_to(:action => :add_participants, :id => @session.id)
        end
      end
    else
      @groups = ExperimentalGroup.all
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

  def status
    @page_title = "Current Status"
    @active_session = ExperimentalSession.active
  end
end
