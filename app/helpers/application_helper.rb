# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_button(button_text, url_options = {})
    form_tag(url_options, :method => "get", :style => "display:inline") +
      "<input type=\"submit\" value=\"#{button_text}\" /></form>"
  end
end
