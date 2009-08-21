class AddLockdownFieldToExperimentalSession < ActiveRecord::Migration
  def self.up
    add_column :experimental_sessions, :is_locked_down, :boolean, :default => false
  end

  def self.down
    remove_column :experimental_sessions, :is_locked_down
  end
end
