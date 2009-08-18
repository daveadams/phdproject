class AddStatusFieldsToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :tutorial_complete, :boolean, :default => false
    add_column :participants, :experiment_complete, :boolean, :default => false
    add_column :participants, :survey_complete, :boolean, :default => false
    add_column :participants, :all_complete, :boolean, :default => false
  end

  def self.down
    remove_column :participants, :all_complete
    remove_column :participants, :survey_complete
    remove_column :participants, :experiment_complete
    remove_column :participants, :tutorial_complete
  end
end
