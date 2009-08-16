class LoginController < ApplicationController
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state
  skip_before_filter :establish_page_order

  def index
  end

  def login
    if request.post?
      @participant = Participant.find_active(params[:participant_number])
      if @participant.nil?
        log_error("Invalid participant number: #{params[:participant_number]}")
        flash[:error] = ErrorStrings::INVALID_PARTICIPANT
        redirect_to(:action => :index)
      else
        begin
          @participant.login
          log_event(ActivityLog::LOGIN, @participant.participant_number)
          session[:participant_id] = @participant.id
          if @participant.phase? and @participant.page?
            # they've been here before, send them back
            redirect_to(:controller => @participant.phase,
                        :action => @participant.page)
          else
            redirect_to(:controller => :tutorial)
          end
        rescue ParticipantAlreadyActive
          log_error("Participant already active: #{@participant.participant_number}")
          flash[:error] = ErrorStrings::ALREADY_ACTIVE
          redirect_to(:action => :index)
        end
      end
    else
      redirect_to(:action => :index)
    end
  end
end
