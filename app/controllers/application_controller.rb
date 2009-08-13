class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  before_filter :require_valid_session

 private
  def require_valid_session
    p = Participant.find(:first, :conditions => ["id=? and is_active=?",
                                                 session[:participant_id],
                                                 true])

    if session[:participant_id].nil? or p.nil?
      flash[:error] = ErrorStrings::MUST_LOGIN
      redirect_to(:controller => "login")
    elsif not p.experimental_session.is_active?
      flash[:error] = ErrorStrings::INACTIVE_SESSION
      redirect_to(:controller => "login")
    end
  end
end
