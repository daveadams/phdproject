class ExperimentalSessionReplaceDatesWithToggle < ActiveRecord::Migration
  def self.up
    remove_column :experimental_sessions, :starts_at
    remove_column :experimental_sessions, :ends_at
    add_column :experimental_sessions, :is_active, :boolean
  end

  def self.down
    remove_column :experimental_sessions, :is_active
    add_column :experimental_sessions, :starts_at, :datetime
    add_column :experimental_sessions, :ends_at, :datetime
  end
end
