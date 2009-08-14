class AddTutorialTextGroupIdToExperimentalGroup < ActiveRecord::Migration
  def self.up
    add_column :experimental_groups, :tutorial_text_group_id, :integer
  end

  def self.down
    remove_column :experimental_groups, :tutorial_text_group_id
  end
end
