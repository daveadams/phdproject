class AddPhaseAndRoundToExperimentalSession < ActiveRecord::Migration
  def self.up
    add_column :experimental_sessions, :phase, :string, :default => "tutorial"
    add_column :experimental_sessions, :round, :integer, :default => 0
  end

  def self.down
    remove_column :experimental_sessions, :round
    remove_column :experimental_sessions, :phase
  end
end
