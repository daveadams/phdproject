class LoginController < ApplicationController
  def index
    if request.post?
      participant = Participant.find_active(request[:participant_number])
      if participant.nil?
        flash[:error] = "Invalid participant number."
      else
        redirect_to(:controller => "tutorial")
      end
    end
  end
end
