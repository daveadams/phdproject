class ExperimentText < ActiveRecord::Base
  belongs_to :experimental_group

  def self.get_text(participant, page_name, text_key)
    t = find(:first,
             :conditions => ["experimental_group_id = ? and page_name = ? and text_key = ?",
                             participant.experimental_group.id,
                             page_name, text_key])
    if t.nil?
      t = find(:first,
               :conditions => ["experimental_group_id is null and page_name = ? and text_key = ?",
                               page_name, text_key])
    end

    if t.nil?
      nil
    else
      t.text
    end
  end
end
