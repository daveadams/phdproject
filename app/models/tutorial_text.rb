class TutorialText < ActiveRecord::Base
  belongs_to :tutorial_text_group

  def self.get_text(participant, page_name, text_key)
    tt = find(:first,
              :conditions => ["tutorial_text_group_id = ? and page_name = ? and text_key = ?",
                              participant.experimental_group.tutorial_text_group.id,
                              page_name, text_key])
    if tt.nil?
      tt = find(:first,
                :conditions => ["tutorial_text_group_id is null and page_name = ? and text_key = ?",
                                page_name, text_key])
    end

    if tt.nil?
      "((Missing Text Definition))"
    else
      tt.text
    end
  end
end

