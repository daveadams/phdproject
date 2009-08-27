class DropEarnedForRoundFieldFromParticipant < ActiveRecord::Migration
  def self.up
    remove_column :participants, :earned_for_round
  end

  def self.down
    add_column :participants, :earned_for_round, :integer, :default => 0
  end
end
