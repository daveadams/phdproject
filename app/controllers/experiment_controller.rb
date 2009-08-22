class ExperimentController < ApplicationController
  before_filter :check_round, :except => [:index, :wait]

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
      redirect_to(:action => :start_round)
    else
      render :action => :wait, :layout => false
    end
  end

  def start_round
    redirect_to(:action => :task)
  end

  def task
  end

  def end_round
    if @participant.round >= @participant.experimental_group.rounds
      redirect_to(:action => :complete)
    else
      @participant.round += 1
      @participant.save
      redirect_to(:action => :wait)
    end
  end

  def complete
    @participant.experiment_complete = true
    @participant.save
  end

 private
  def check_round
    if @participant.round > @participant.experimental_session.round
      redirect_to(:action => :wait)
    end
  end
end
