class TutorialController < ApplicationController
  def index
    redirect_to(:controller => "login")
  end
end
