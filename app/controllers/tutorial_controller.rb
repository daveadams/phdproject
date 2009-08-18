class TutorialController < ApplicationController
  def index
    redirect_to(:action => @page_order[0])
  end

  def intro; end
  def overview; end

  def earnings_intro; end
  def earnings_task; end
  def earnings_report; end

  def tax_intro; end
  def tax_return; end

  def disclosure_intro; end
  def disclosure_report; end

  def audit_intro; end
  def audit_notify; end
  def audit_ok; end
  def audit_error; end

  def doublecheck_intro; end
  def doublecheck_notify; end
  def doublecheck_ok; end
  def doublecheck_error; end

  def completing; end

  def complete
    @participant.tutorial_complete = true
    @participant.save
  end
end
