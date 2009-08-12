class AdminController < ApplicationController
  def participants
    @participants = Participant.find(:all)
  end
end
