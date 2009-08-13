class LoginController < ApplicationController
  def index
  end

  def login
    if request.post?
      participant = Participant.find_active(request[:participant_number])
      if participant.nil?
        flash[:error] = "Invalid participant number. Please try again."
        redirect_to(:action => :index)
      else
        begin
          participant.login
          session[:participant_id] = participant.id
          redirect_to(:controller => :tutorial)
        rescue ParticipantAlreadyActive
          flash[:error] = "That participant number is already in use. Please notify the staff."
          redirect_to(:action => :index)
        end
      end
    else
      redirect_to(:action => :index)
    end
  end
end
