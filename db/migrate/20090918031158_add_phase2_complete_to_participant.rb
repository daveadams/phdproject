class AddPhase2CompleteToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :phase2_complete, :boolean, :default => false
  end

  def self.down
    remove_column :participants, :phase2_complete
  end
end
