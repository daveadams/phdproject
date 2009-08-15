class TutorialController < ApplicationController
  before_filter :establish_page_order

  def index
    redirect_to(:action => @page_order[0])
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
  def establish_page_order
    @page_order = PageOrder.find(:first,
                                 :conditions => ["experimental_group_id=? and phase=?",
                                                 @participant.experimental_group.id,
                                                 controller_name]).page_order
  end
end
