class AddWasForcedToExperimentalSession < ActiveRecord::Migration
  def self.up
    add_column :experimental_sessions, :was_forced, :boolean, :default => false
  end

  def self.down
    remove_column :experimental_sessions, :was_forced
  end
end
