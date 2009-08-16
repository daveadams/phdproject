class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  before_filter :require_valid_session
  before_filter :update_participant_state
  before_filter :establish_page_order
  before_filter :log_page_load

 protected
  # override default error handling
  def rescue_action_in_public(exception)
    logger.error "CRITICAL ERROR: #{exception.class}: #{exception}"
    begin
      ActivityLog.create!(:event => ActivityLog::CRITICAL,
                          :participant_id => @participant.nil? ? nil : @participant.id,
                          :controller => controller_name,
                          :action => action_name,
                          :details => "#{exception.class}: #{exception}")
    rescue => e
      logger.fatal "FATAL ERROR: Could not create error record in activity log."
      logger.fatal "             #{e.class}: #{e}"
    end
    render :file => File.join(Rails.public_path, "error.html")
  end

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

  def log_page_load
      log_event(ActivityLog::PAGE_LOADED, params.to_yaml)
  end

  def log_event(event, details = nil)
    ActivityLog.create(:event => event,
                       :participant_id => @participant.nil? ? nil : @participant.id,
                       :controller => controller_name,
                       :action => action_name,
                       :details => details)
  end

  def log_app_error(error_message)
    log_event(ActivityLog::ERROR, error_message)
  end
end
