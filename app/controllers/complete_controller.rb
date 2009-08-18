class CompleteController < ApplicationController
  def index
    @participant.all_complete = true
    @participant.save
    reset_session
  end
end
