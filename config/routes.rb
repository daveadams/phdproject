ActionController::Routing::Routes.draw do |map|
  # go to login by default
  map.root :controller => "login"

  # standard default route
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
