class LoginController < ApplicationController
  def index
    if request.post?
      participant = Participant.find_active(request[:participant_number])
      if participant.nil?
        flash[:error] = "Invalid participant number. Please try again."
      else
        begin
          participant.login
          session[:participant_id] = participant.id
          redirect_to(:controller => "tutorial")
        rescue ParticipantAlreadyActive
          flash[:error] = "That participant number is already in use. Please notify the staff."
        end
      end
    end
  end
end
