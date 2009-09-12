class AddForcedFlagToParticipant < ActiveRecord::Migration
  def self.up
    add_column :participants, :was_forced, :boolean, :default => false
  end

  def self.down
    remove_column :participants, :was_forced
  end
end
