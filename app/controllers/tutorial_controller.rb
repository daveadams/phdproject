class TutorialController < ApplicationController
  def index
    redirect_to(:action => @page_order[0])
  end

  def intro; end
  def earnings; end
  def taxes; end
  def report; end
  def audit; end
  def doublecheck; end
  def complete; end
end
