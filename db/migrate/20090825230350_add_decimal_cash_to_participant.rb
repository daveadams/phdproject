class AddDecimalCashToParticipant < ActiveRecord::Migration
  def self.up
    remove_column :participants, :cash
    add_column :participants, :cash, :decimal, :precision => 8, :scale => 2, :default => 0.00
  end

  def self.down
    remove_column :participants, :cash
    add_column :participants, :cash, :integer, :default => 0
  end
end
