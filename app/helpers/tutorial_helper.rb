module TutorialHelper
  def get_text(text_key)
    TutorialText.get_text(@participant, action_name, text_key)
  end

  def next_page
    current_index = @page_sequence.index(action_name)
    if current_index >= (@page_sequence.length - 1)
      nil
    else
      @page_sequence[current_index + 1]
    end
  end

  def prev_page
    current_index = @page_sequence.index(action_name)
    if current_index <= 0
      nil
    else
      @page_sequence[current_index - 1]
    end
  end
end
