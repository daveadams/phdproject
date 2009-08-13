class LoginController < ApplicationController
  skip_before_filter :require_valid_session

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
          redirect_to(:controller => :tutorial)
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
