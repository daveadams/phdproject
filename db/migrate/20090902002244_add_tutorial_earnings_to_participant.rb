class AddTutorialEarningsToParticipant < ActiveRecord::Migration
  def self.up
    add_column(:participants, :tutorial_cash, :decimal,
               :precision => 8, :scale => 2, :default => 0.0)
  end

  def self.down
    remove_column :participants, :tutorial_cash
  end
end
