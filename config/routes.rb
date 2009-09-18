ActionController::Routing::Routes.draw do |map|
  # go to login by default
  map.root :controller => "login"

  map.connect 'experiment/choices', :controller => :phase2, :action => :index
  map.connect 'experiment/submit_choices', :controller => :phase2, :action => :submit_choices
  map.connect 'experiment/done', :controller => :phase2, :action => :done

  # standard default route
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
