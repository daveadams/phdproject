class AdminController < ApplicationController
  skip_before_filter :require_valid_session
  skip_before_filter :update_participant_state

  def participants
    @participants = Participant.find(:all)
  end

  def status
    @sessions = ExperimentalSession.find_all_by_is_active(true)
  end
end
