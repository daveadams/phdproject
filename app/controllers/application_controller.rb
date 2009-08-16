class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  before_filter :require_valid_session
  before_filter :update_participant_state
  before_filter :establish_page_order

 private
  def require_valid_session
    @participant = Participant.find(:first, :conditions => ["id=? and is_active=?",
                                                            session[:participant_id],
                                                            true])

    if session[:participant_id].nil? or @participant.nil?
      flash[:error] = ErrorStrings::MUST_LOGIN
      redirect_to(:controller => "login")
    elsif not @participant.experimental_session.is_active?
      flash[:error] = ErrorStrings::INACTIVE_SESSION
      redirect_to(:controller => "login")
    end
  end

  def update_participant_state
    if @participant
      @participant.last_access = Time.now
      @participant.phase = controller_name
      @participant.page = action_name
      @participant.save
    end
  end

  def establish_page_order
    @page_order = PageOrder.find(:first,
                                 :conditions => ["experimental_group_id=? and phase=?",
                                                 @participant.experimental_group.id,
                                                 controller_name]).page_order
  end
end
