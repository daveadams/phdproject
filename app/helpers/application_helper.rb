module ApplicationHelper
  def link_button(button_text, url_options = {})
    form_tag(url_options, :method => "get", :style => "display:inline") +
      "<input type=\"submit\" value=\"#{button_text}\" /></form>"
  end

  def rule_filter(raw_text)
    data = @participant.experimental_group.rules
    raw_text.gsub(/\{\{\{([^}]+)\}\}\}/) { data[$1.downcase.strip].to_s || $1 }
  end

  def get_text(text_key)
    raw_text = if controller_name == "tutorial"
                 TutorialText.get_text(@participant, action_name, text_key)
               elsif controller_name == "experiment"
                 ExperimentText.get_text(@participant, action_name, text_key)
               else
                 nil
               end
    if raw_text.nil?
      nil
    else
      if !@participant.nil? and raw_text =~ /\{\{\{[^}]+\}\}\}/
        rule_filter(raw_text)
      else
        raw_text
      end
    end
  end
end
