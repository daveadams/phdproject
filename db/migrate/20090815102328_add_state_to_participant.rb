class AddStateToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :phase, :string
    add_column :participants, :page, :string
    add_column :participants, :round, :integer, :default => 0
    add_column :participants, :cash, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    remove_column :participants, :cash
    remove_column :participants, :round
    remove_column :participants, :page
    remove_column :participants, :phase
  end
end
