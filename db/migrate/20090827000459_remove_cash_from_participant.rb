class RemoveCashFromParticipant < ActiveRecord::Migration
  def self.up
    remove_column :participants, :cash
  end

  def self.down
    add_column :participants, :cash, :precision => 8, :scale => 2, :default => 0
  end
end
