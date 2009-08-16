class AdminController < ApplicationController
  skip_before_filter :check_session
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state
  skip_before_filter :establish_page_order
  skip_before_filter :log_page_load
  skip_before_filter :enforce_order

  def participants
    @participants = Participant.find(:all)
  end

  def status
    @sessions = ExperimentalSession.find_all_by_is_active(true)
  end
end
