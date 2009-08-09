class LoginController < ApplicationController
  def index
    if request.post?
      redirect_to(:controller => "tutorial")
    end
  end
end
