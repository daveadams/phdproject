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
    @page_sequence = case @participant.group_name
                     when "tax":
                         ["intro","earnings","taxes","audit","complete"]
                     when "neutral":
                         ["intro","earnings","report","doublecheck","complete"]
                     end
  end
end
