class LoginController < ApplicationController
  def index
    if request.post?
      participant = Participant.find(:first,
                                     :conditions => ["participant_number = ?",
                                                     request[:participant_number]])
      if participant.nil?
        flash[:error] = "Invalid participant number."
      else
        redirect_to(:controller => "tutorial")
      end
    end
  end
end
