class Phase2Controller < ApplicationController
  skip_before_filter :establish_page_order
  before_filter :check_phase

  def index
    if @participant.choices_made?
      redirect_to(:action => :done)
    else
      @page_title = "Decision Choices"
      @choices = @participant.choices
    end
  end

  def submit_choices
    if @participant.choices_made?
      redirect_to(:action => :done)
    else
      if request.post?
        0.upto 9 do |i|
          if %w( L R ).include? request["choice#{i}"]
            eval("@participant.gamble#{i} = request[\"choice#{i}\"]")
          end
        end
        @participant.save
        if @participant.choices_made?
          redirect_to(:action => :done)
        else
          flash[:error] = "Please answer all the questions."
          redirect_to(:action => :index)
        end
      else
        redirect_to(:action => :index)
      end
    end
  end

  def done
    if not @participant.choices_made?
      redirect_to(:action => :index)
    else
      if request.post?
        @participant.phase2_complete = true
        @participant.save

        redirect_to(:controller => :survey)
      else
        @page_title = "Work Complete"
      end
    end
  end

 private
  def check_phase
    if @participant.survey_complete
      redirect_to(:controller => :complete)
    elsif @participant.phase2_complete
      redirect_to(:controller => :survey)
    elsif not @participant.experiment_complete
      redirect_to(:controller => :experiment)
    elsif not @participant.tutorial_complete
      redirect_to(:controller => :tutorial)
    end
  end
end
