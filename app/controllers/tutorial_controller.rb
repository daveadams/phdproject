class TutorialController < ApplicationController
  before_filter :determine_page_sequence

  def index
    redirect_to(:action => @page_sequence[0])
  end

  def intro
  end

  def earnings
  end

  def taxes
  end
  alias :report :taxes

  def audit
  end
  alias :doublecheck :audit

  def complete
  end

 private
  def determine_page_sequence
    @page_sequence = case @participant.experimental_group.tutorial_text_group.name
                     when "Normal":
                         ["intro","earnings","taxes","audit","complete"]
                     when "Context-Neutral":
                         ["intro","earnings","report","doublecheck","complete"]
                     end
  end
end
