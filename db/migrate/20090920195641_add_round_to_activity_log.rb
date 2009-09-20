class AddRoundToActivityLog < ActiveRecord::Migration
  def self.up
    add_column :activity_logs, :round, :integer
  end

  def self.down
    remove_column :activity_logs, :round
  end
end
