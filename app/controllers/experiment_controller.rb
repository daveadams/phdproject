class ExperimentController < ApplicationController
  def index
  end

  def wait
    # TODO: add reload to layout for this action
    # TODO: check phase/round status and advance as appropriate
  end

  def complete
    @participant.experiment_complete = true
    @participant.save
  end
end
