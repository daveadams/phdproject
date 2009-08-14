class LinkTutorialTextToTutorialTextGroup < ActiveRecord::Migration
  def self.up
    remove_column :tutorial_texts, :group_name
    add_column :tutorial_texts, :tutorial_text_group_id, :integer
  end

  def self.down
    remove_column :tutorial_texts, :tutorial_text_group_id
    add_column :tutorial_texts, :group_name, :string
  end
end
