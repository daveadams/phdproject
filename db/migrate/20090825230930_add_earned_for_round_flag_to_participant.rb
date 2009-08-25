class AddEarnedForRoundFlagToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :earned_for_round, :integer, :default => 0
  end

  def self.down
    remove_column :participants, :earned_for_round
  end
end
