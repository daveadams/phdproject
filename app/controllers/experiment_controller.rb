class ExperimentController < ApplicationController
  def index
  end

  def complete
    @participant.experiment_complete = true
    @participant.save
  end
end
