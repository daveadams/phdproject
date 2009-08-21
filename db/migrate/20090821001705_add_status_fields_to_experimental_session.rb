class AddStatusFieldsToExperimentalSession < ActiveRecord::Migration
  def self.up
    add_column :experimental_sessions, :started_at, :datetime
    add_column :experimental_sessions, :ended_at, :datetime
    add_column :experimental_sessions, :is_complete, :boolean, :default => false
    change_column_default :experimental_sessions, :is_active, false
  end

  def self.down
    remove_column :experimental_sessions, :is_complete
    remove_column :experimental_sessions, :ended_at
    remove_column :experimental_sessions, :started_at
  end
end
