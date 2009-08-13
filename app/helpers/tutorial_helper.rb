module TutorialHelper
  def get_text(text_key)
    group_name = @participant.group_name
    page_name = action_name
    tt = TutorialText.find(:first, :conditions => ["group_name = ? and page_name = ? and text_key = ?",
                                                   group_name, page_name, text_key])
    if tt.nil?
      tt = TutorialText.find(:first, :conditions => ["group_name is null and page_name = ? and text_key = ?",
                                                     page_name, text_key])
    end

    if tt.nil?
      "SYSTEM ERROR: Missing Text"
    else
      tt.text
    end
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
