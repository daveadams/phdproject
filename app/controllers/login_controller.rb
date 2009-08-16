class LoginController < ApplicationController
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state
  skip_before_filter :establish_page_order

  def index
  end

  def login
    if request.post?
      participant = Participant.find_active(request[:participant_number])
      if participant.nil?
        flash[:error] = ErrorStrings::INVALID_PARTICIPANT
        redirect_to(:action => :index)
      else
        begin
          participant.login
          session[:participant_id] = participant.id
          if participant.phase? and participant.page?
            # they've been here before, send them back
            redirect_to(:controller => participant.phase,
                        :action => participant.page)
          else
            redirect_to(:controller => :tutorial)
          end
        rescue ParticipantAlreadyActive
          flash[:error] = ErrorStrings::ALREADY_ACTIVE
          redirect_to(:action => :index)
        end
      end
    else
      redirect_to(:action => :index)
    end
  end
end
