module TutorialHelper
  def get_text(text_key)
    TutorialText.get_text(@participant, action_name, text_key)
  end

  def next_page
    current_index = @page_order.index(action_name)
    if current_index >= (@page_order.length - 1)
      nil
    else
      @page_order[current_index + 1]
    end
  end

  def prev_page
    current_index = @page_order.index(action_name)
    if current_index <= 0
      nil
    else
      @page_order[current_index - 1]
    end
  end
end
