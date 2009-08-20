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
  end

  def create_participants
  end

  def status
    @active_session = ExperimentalSession.active
  end
end
