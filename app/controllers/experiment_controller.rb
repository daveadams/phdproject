class ExperimentController < ApplicationController
  def index
    if @participant.tutorial_complete
      if not @participant.experiment_complete
        redirect_to(:action => :wait)
      else
        redirect_to(:controller => :survey)
      end
    end
  end

  def wait
    if @participant.experimental_session.phase == "experiment" and
        @participant.experimental_session.round == @participant.round
      redirect_to(:action => :start)
    else
      render :action => :wait, :layout => false
    end
  end

  def start

  end

  def complete
    @participant.experiment_complete = true
    @participant.save
  end
end
