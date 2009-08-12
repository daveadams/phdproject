class TutorialController < ApplicationController
  before_filter :require_valid_session

  def index
  end

 private
  def require_valid_session
    p = Participant.find(:first, :conditions => ["id=? and is_active=?",
                                                 session[:participant_id],
                                                 true])

    if session[:participant_id].nil? or p.nil?
      flash[:error] = "You must login before using the application."
      redirect_to(:controller => "login")
    elsif not p.experimental_session.is_active?
      flash[:error] = "This experimental session has ended. Please see the staff."
      redirect_to(:controller => "login")
    end
  end
end
